

public struct WebDAVFindChangedDirectoriesResult {
    
    public var files = [WebDAVFile]()
    
    public var unchangedDirectories = [WebDAVFile]()
}

public struct WebDAVFilesDiff {
    public struct UpdatedFile {
        public let localFile: WebDAVFile
        public let remoteFile: WebDAVFile
        
        public var contentChanged: Bool {
            remoteFile[.etag] != localFile[.etag]
        }
        public var pathChanged: Bool {
            remoteFile.path != localFile.path
        }

        public init?(localFile: WebDAVFile, remoteFile: WebDAVFile) {
            self.localFile = localFile
            self.remoteFile = remoteFile
            
            guard self.contentChanged || self.pathChanged else { return nil }
        }
    }
    
    public var new = [WebDAVFile]()

    public var updated = [UpdatedFile]()
    
    public var deleted = [WebDAVFile]()
    
    
    public var isEmpty: Bool {
        new.isEmpty && updated.isEmpty && deleted.isEmpty
    }
}

extension WebDAVSession {

    private func _listFilesOfChangedDirectories(directory: AbsoluteWebDAVPath, properties: [WebDAVFilePropertyFetchKey], account: any WebDAVAccount, didChange: @escaping (_ file: WebDAVFile) -> Bool) async throws -> WebDAVFindChangedDirectoriesResult {

        let files = try await self.listFiles(at: directory, properties: properties, depth: .one, account: account)
        // FIXME: use resourcetype
        var changedSubDirectories: [WebDAVFile] = []
        
        var result = WebDAVFindChangedDirectoriesResult()
        for file in files {
            if file[.contentType] != nil {
                result.files.append(file)
            } else if didChange(file) {
                if file.path.relativePath != "/" {
                    changedSubDirectories.append(file)
                }
                result.files.append(file)
            } else {
                result.unchangedDirectories.append(file)
            }
        }
        
        // recusively walk subdirectories
        let recursiveWalkResult = try await withThrowingTaskGroup(of: WebDAVFindChangedDirectoriesResult.self) { group in
            var recursiveWalkResult = WebDAVFindChangedDirectoriesResult()
            
            for subDirectory in changedSubDirectories {
                // if a subdirectory did change its etag, we walk it and its subdirectories by recursion
                group.addTask {
                    var subResult = try await self._listFilesOfChangedDirectories(directory: .init(subDirectory.path), properties: properties, account: account, didChange: didChange)
                    subResult.files.removeFirst { element in
                        element.path.relativePath == "/"
                    }
                    return subResult
                }
            }
            
            for try await subResult in group {
                recursiveWalkResult.files.append(contentsOf: subResult.files)
                recursiveWalkResult.unchangedDirectories.append(contentsOf: subResult.unchangedDirectories)
            }
            
            return recursiveWalkResult
        }
        
        // combine result of directory and its subdirectory
        result.files.append(contentsOf: recursiveWalkResult.files)
        result.unchangedDirectories.append(contentsOf: recursiveWalkResult.unchangedDirectories)
        return result
    }
    
    public func listFilesOfChangedDirectories(directory: any AbsoluteWebDAVPathProtocol, properties: [WebDAVFilePropertyFetchKey], account: any WebDAVAccount, didChange: @escaping (_ file: WebDAVFile) -> Bool) async throws -> WebDAVFindChangedDirectoriesResult {
        var properties = properties
        if !properties.contains(.contentType) {
            properties.append(.contentType)
        }
        
        guard let rootDirectory = try await self.listFiles(at: directory, properties: [.etag], depth: .zero, account: account).first else {
            throw WebDAVError.notFound
        }
        guard didChange(rootDirectory) else {
            return .init(files: [], unchangedDirectories: [rootDirectory])
        }
        
        let result = try await self._listFilesOfChangedDirectories(directory: AbsoluteWebDAVPath(directory), properties: properties, account: account, didChange: didChange)
        
        guard let rootDirectoryAfterwards = try await self.listFiles(at: directory, properties: [.etag], depth: .zero, account: account).first else {
            throw WebDAVError.notFound
        }
        guard rootDirectory[.etag] == rootDirectoryAfterwards[.etag] else {
            throw WebDAVError.etagChangedDuringIteration
        }
        
        return result
    }
    
    public func diff(directory: any AbsoluteWebDAVPathProtocol, properties: [WebDAVFilePropertyFetchKey], localFiles: [WebDAVFile], account: any WebDAVAccount) async throws -> WebDAVFilesDiff {
        var pathToLocalFile = Dictionary(localFiles.map {($0.path, $0)}) {a, b in
            a
        }
        let remoteChangedFiles = try await self.listFilesOfChangedDirectories(directory: directory, properties: properties, account: account) { file in
            pathToLocalFile[file.path]?.propery(.etag) != file[.etag]
        }
        pathToLocalFile = pathToLocalFile.filter { (filePath, _) in
            remoteChangedFiles.unchangedDirectories.allSatisfy { !$0.path.isSubpath(of: filePath) }
        }
        return Self._diff(pathToLocalFile: pathToLocalFile, remoteFiles: remoteChangedFiles.files)
    }
    
    private static func _diff(pathToLocalFile: [RelativeWebDAVPath: WebDAVFile], remoteFiles: [WebDAVFile]) -> WebDAVFilesDiff {
        var result = WebDAVFilesDiff()
        
        var etagToLocalFile = Dictionary(grouping: pathToLocalFile.values.compactMap { (file: WebDAVFile) -> (String, WebDAVFile)? in
            guard let etag = file[.etag] else { return nil }
            return (etag, file)
        })
        
        
        let fileIdToLocalFile = Dictionary(pathToLocalFile.values.compactMap { (file: WebDAVFile) -> (String, WebDAVFile)? in
            guard let fileId = file.propery(.ownCloudFileId) else { return nil }
            return (fileId, file)
        }) {a, b in
            a
        }
        // TODO: Check that resource type stayed the same!
        
        var deletedPaths = Set<RelativeWebDAVPath>(pathToLocalFile.keys)
        
        for remoteFile in remoteFiles {
            
            if let fileId = remoteFile[.ownCloudFileId], let localFile = fileIdToLocalFile[fileId] {
                // This is the "best case". Since the fileId is guaranteed to be unique, we can now determine what happened to the file.
                deletedPaths.remove(localFile.path)
                
                if let fileChange = WebDAVFilesDiff.UpdatedFile(localFile: localFile, remoteFile: remoteFile) {
                    result.updated.append(fileChange)
                }
            } else if let remoteEtag = remoteFile[.etag], var etagMatches = etagToLocalFile[remoteEtag], !etagMatches.isEmpty {
                if let localFile = etagMatches.removeFirst(where: { $0.path == remoteFile.path }) {
                    // Path and Etag are equal, nothing happened to this file
                    deletedPaths.remove(localFile.path)
                } else {
                    // The file was moved
                    let localFile = etagMatches.removeFirst()
                    deletedPaths.remove(localFile.path)
                    
                    result.updated.append(.init(localFile: localFile, remoteFile: remoteFile)!)
                }
                
                etagToLocalFile[remoteEtag] = etagMatches
                
            } else if let localFile = pathToLocalFile[remoteFile.path] {
                // We found a file with the same path, but the content may have been changed
                deletedPaths.remove(localFile.path)
                
                if let fileChange = WebDAVFilesDiff.UpdatedFile(localFile: localFile, remoteFile: remoteFile) {
                    result.updated.append(fileChange)
                }
            } else {
                // If there is not original with matching fileId, etag or path, the file is new
                result.new.append(remoteFile)
            }
        }

        for deletedPath in deletedPaths {
            result.deleted.append(pathToLocalFile[deletedPath]!)
        }
        
        return result
    }

    public static func diff(localFiles: [WebDAVFile], remoteFiles: [WebDAVFile]) -> WebDAVFilesDiff {
        let pathToLocalFile = Dictionary(localFiles.map {($0.path, $0)}) {a, b in
            a
        }
        
        return _diff(pathToLocalFile: pathToLocalFile, remoteFiles: remoteFiles)
    }
}

extension Dictionary {
    init<ValueElement>(grouping pairs: any Sequence<(Key, ValueElement)>) where Value == [ValueElement] {
        self = .init(minimumCapacity: pairs.underestimatedCount)
        for (key, value) in pairs {
            self[key, default: .init()].append(value)
        }
    }
}

extension Array {
    @discardableResult
    mutating func removeFirst(where selection: (_ element: Element) throws -> Bool) rethrows -> Element? {
        if let index = try self.firstIndex(where: selection) {
            return self.remove(at: index)
        }
        return nil
    }
}
