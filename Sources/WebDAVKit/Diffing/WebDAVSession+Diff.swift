//
//  File.swift
//  
//
//  Created by Matteo Ludwig on 11.12.23.
//

import Foundation


/// Represents files found on the remote.
/// If a directory did not change (i.e. its etag is equal to its cached etag), its files are not included in the files array, but the directory will be included in skippedDirectories.
public struct WebDAVFindChangedDirectoriesResult {
    
    /// Files found on remote. Does not include all files of remote since directories might be skipped (see unchangedDirectories).
    public var files = [WebDAVFile]()
    
    /// Directories that were skipped while walking the filesystem of the remote because their etag did not change
    public var unchangedDirectories = [WebDAVFile]()
}

public struct RemoteFilesDiff {
    public struct FileChange {
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
    
    /// Files found on the remote that are not saved as an IndexedAssetModel
    public var new = [WebDAVFile]()

    /// Files found on the remote that have either changed their content or path ore were previously deleted and now restored (or a comibnation of those)
    public var changed = [FileChange]()
    
    /// IndexedAssetModels that are saved locally but are no longer on the remote
    public var deleted = [WebDAVFile]()
}

extension WebDAVSession {

    /// Creates a RemoteFileWalkResult using WebDAV requests to walk the directory and its subdirectory.
    /// - Parameter directory: The directory to walk.
    /// - Returns: A RemoteFileWalkResult of found files and skipped directories
    private func _listFilesOfChangedDirectories(directory: any AbsoluteWebDAVPathProtocol, properties: [WebDAVFilePropertyFetchKey], account: any WebDAVAccount, didChange: @escaping (_ file: WebDAVFile) -> Bool) async throws -> WebDAVFindChangedDirectoriesResult {

        let files = try await self.listFiles(at: directory, properties: properties, depth: .one, account: account)
        // FIXME: use resourcetype
        let subDirectories = files.filter { $0.propery(.contentType) == nil }
        
        var result = WebDAVFindChangedDirectoriesResult()
        
        // recusively walk subdirectories
        let recursiveWalkResult = try await withThrowingTaskGroup(of: WebDAVFindChangedDirectoriesResult.self) { group in
            var subResult = WebDAVFindChangedDirectoriesResult()
            
            for subDirectory in subDirectories {
                // skip subdirectories that have not changed their etag
                guard didChange(subDirectory) else {
                    subResult.unchangedDirectories.append(subDirectory)
                    continue
                }
                // if a subdirectory did change its etag, we walk it and its subdirectories by recursion
                group.addTask {
                    return try await self._listFilesOfChangedDirectories(directory: directory, properties: properties, account: account, didChange: didChange)
                }
            }
            
            // combine results of subdirectories into a single result
            subResult = try await group.reduce(into: subResult) { partialResult, walkResult in
                partialResult.files.append(contentsOf: walkResult.files)
                partialResult.unchangedDirectories.append(contentsOf: walkResult.unchangedDirectories)
            }
            
            return subResult
        }
        
        // combine result of directory and its subdirectory
        result.files.append(contentsOf: files)
        result.files.append(contentsOf: recursiveWalkResult.files)
        result.unchangedDirectories.append(contentsOf: recursiveWalkResult.unchangedDirectories)
        return result
    }
    
    /// Creates a RemoteFileWalkResult using WebDAV requests to walk the directory and its subdirectory.
    /// - Parameter directory: The directory to walk.
    /// - Returns: A RemoteFileWalkResult of found files and skipped directories
    public func listFilesOfChangedDirectories(directory: any AbsoluteWebDAVPathProtocol, properties: [WebDAVFilePropertyFetchKey], account: any WebDAVAccount, didChange: @escaping (_ file: WebDAVFile) -> Bool) async throws -> WebDAVFindChangedDirectoriesResult {
        var properties = properties
        if !properties.contains(.contentType) {
            properties.append(.contentType)
        }
        
        guard let rootDirectory = try await self.listFiles(at: directory, properties: [.etag], account: account).first else {
            throw WebDAVError.notFound
        }
        guard didChange(rootDirectory) else {
            return .init(files: [], unchangedDirectories: [rootDirectory])
        }
        
        let result = try await self._listFilesOfChangedDirectories(directory: directory, properties: properties, account: account, didChange: didChange)
        
        guard let rootDirectoryAfterwards = try await self.listFiles(at: directory, properties: [.etag], account: account).first else {
            throw WebDAVError.notFound
        }
        guard rootDirectory[.etag] == rootDirectoryAfterwards[.etag] else {
            throw WebDAVError.etagChangedDuringIteration
        }
        
        return result
    }
    
    public func diff(directory: any AbsoluteWebDAVPathProtocol, properties: [WebDAVFilePropertyFetchKey], localFiles: [WebDAVFile], account: any WebDAVAccount) async throws -> RemoteFilesDiff {
        var pathToLocalFile = Dictionary(localFiles.map {($0.path, $0)}) {a, b in
            a
        }
        let remoteChangedFiles = try await self.listFilesOfChangedDirectories(directory: directory, properties: properties, account: account) { file in
            pathToLocalFile[file.path]?.propery(.etag) != file[.etag]
        }
        pathToLocalFile = pathToLocalFile.filter { (filePath, _) in
            remoteChangedFiles.unchangedDirectories.allSatisfy { $0.path.isSubpath(of: filePath) }
        }
        return Self._diff(pathToLocalFile: pathToLocalFile, remoteFiles: remoteChangedFiles.files)
    }
    
    // Figures out what changed on the remote compared to the local database.
    /// - Parameter remoteFiles: The files currently on the remote.
    /// - Parameter timestamp: A timestamp of when the request that resulted in given remoteFiles was started.
    /// - Parameter ignoredDirectories: IndexedAssetModels from directories in this array will not be deleted, even when not included in remoteFiles.
    /// - Returns: A RemoteChanges struct describing the changes on the remote.
    private static func _diff(pathToLocalFile: [RelativeWebDAVPath: WebDAVFile], remoteFiles: [WebDAVFile]) -> RemoteFilesDiff {
        var result = RemoteFilesDiff()
        
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
        
        
        // A set of IndexedAssetModels that must not be deleted (i.e. file was moved, changed, etc...)
        var deletedPaths = Set<RelativeWebDAVPath>(pathToLocalFile.keys)
        
        for remoteFile in remoteFiles {
            
            if let fileId = remoteFile[.ownCloudFileId], let localFile = fileIdToLocalFile[fileId] {
                // This is the "best case". Since the fileId is guaranteed to be unique, we can now determine what happened to the file.
                deletedPaths.remove(localFile.path)
                
                if let fileChange = RemoteFilesDiff.FileChange(localFile: localFile, remoteFile: remoteFile) {
                    result.changed.append(fileChange)
                }
            } else if let remoteEtag = remoteFile[.etag], var etagMatches = etagToLocalFile[remoteEtag], !etagMatches.isEmpty {
                if let localFile = etagMatches.removeFirst(where: { $0.path == remoteFile.path }) {
                    // Path and Etag are equal, nothing happened to this file
                    deletedPaths.remove(localFile.path)
                } else {
                    // The file was moved
                    let localFile = etagMatches.removeFirst()
                    deletedPaths.remove(localFile.path)
                    
                    result.changed.append(.init(localFile: localFile, remoteFile: remoteFile)!)
                }
                
                etagToLocalFile[remoteEtag] = etagMatches
                
            } else if let localFile = pathToLocalFile[remoteFile.path] {
                // We found a file with the same path, but the content may have been changed
                deletedPaths.remove(localFile.path)
                
                if let fileChange = RemoteFilesDiff.FileChange(localFile: localFile, remoteFile: remoteFile) {
                    result.changed.append(fileChange)
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
    
    /// Figures out what changed on the remote compared to the local database.
    /// - Parameter remoteFiles: The files currently on the remote.
    /// - Parameter timestamp: A timestamp of when the request that resulted in given remoteFiles was started.
    /// - Parameter ignoredDirectories: IndexedAssetModels from directories in this array will not be deleted, even when not included in remoteFiles.
    /// - Returns: A RemoteChanges struct describing the changes on the remote.
    public static func diff(localFiles: [WebDAVFile], remoteFiles: [WebDAVFile]) -> RemoteFilesDiff {
        var pathToLocalFile = Dictionary(localFiles.map {($0.path, $0)}) {a, b in
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
