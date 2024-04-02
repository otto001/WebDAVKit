//  WebDAVFileTree.swift
//  WebDAVKit
//
//  Created by Matteo Ludwig on 29.11.23.
//  Licensed under the MIT-License included in the project.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//


import Foundation

/// A tree structure to store WebDAV files. 
/// The tree is based on the path components of the files. Therefore, the tree allows for fast lookup and removal of whole subtrees (i.e., directories).
/// The root node is the base path of the tree. The tree is not thread-safe.
struct WebDAVFileTree {
    /// A node in the tree. Contains a file and a reference to parent and child nodes.
    fileprivate class Node {
        /// The path component of the node.
        let name: String

        /// The file stored in the node.
        var file: WebDAVFile

        /// The parent node. Only nil for the root node. When updated, automatically removes the node from the children of the old parent and adds it to the children of the new parent.
        weak var parent: Node? {
            didSet {
                guard oldValue !== self.parent else { return }
                oldValue?.children[self.name] = nil
                self.parent?.children[self.name] = self
            }
        }

        /// A dictionary of child nodes. Key is the path component of the child node.
        private(set) var children: [String: Node]
        
        /// Creates a new node with a given name and parent node. Used for creating the root node only.
        init(name: String, basePath: RelativeWebDAVPath) {
            self.name = name
            self.parent = nil
            self.children = [:]
            
            self.file = WebDAVFile(path: basePath)
        }
        
        /// Creates a new node with a given name and parent node. Used for creating all nodes besides the root node. Automatically adds the node to the parent's children.
        init(name: String, parent: Node) {
            self.name = name
            self.parent = parent
            self.children = [:]

            self.file = WebDAVFile(path: parent.file.path.appending(name))
            
            parent.children[self.name] = self
        }
        
        /// The path components of the node. The path is the concatenation of the individual path components of the node and all its parent nodes.
        var pathComponents: [String] {
            var result: [String] = [name]
            var iter = self
            while let next = iter.parent {
                result.append(next.name)
                iter = next
            }
            
            return Array(result.reversed())
        }
        
        /// The path of the node. The path is the concatenation of the individual path components of the node and all its parent nodes.
        var path: WebDAVPath {
            WebDAVPath(pathComponents)
        }
    }
    
    /// The root node of the tree.
    private var rootNode: Node? = nil

    /// The number of files in the tree.
    private(set) var count: Int = 0

    /// The base path of the tree. All files in the tree are below this path.
    let basePath: AbsoluteWebDAVPath
    
    /// Creates a new file tree with a given base path.
    /// - Parameter basePath: The base path of the tree. All files in the tree are below this path.
    init(basePath: any AbsoluteWebDAVPathProtocol) {
        self.basePath = AbsoluteWebDAVPath(basePath)
        //self.rootNode = .init(name: "", basePath: RelativeWebDAVPath(relativePath: "", relativeTo: AbsoluteWebDAVPath(basePath)))
    }
    
    /// Returns the node at a given path. Returns nil if the node does not exist.
    /// - Parameter pathComponents: The path components of the node.
    /// - Returns: The node at the given path if it exists.
    private func node(pathComponents: [String]) -> Node? {
        guard var iter = rootNode else { return nil }
        for nextComponent in pathComponents {
            guard let next = iter.children[nextComponent] else {
                return nil
            }
            iter = next
        }
        
        return iter
    }
    
    /// Creates a node at a given path. If the node already exists, returns the existing node.
    /// - Parameter pathComponents: The path components of the node.
    /// - Returns: The node at the given path.
    mutating private func makeNode(pathComponents: [String]) -> Node {
        if rootNode == nil {
            rootNode = .init(name: "", basePath: RelativeWebDAVPath(relativePath: "", relativeTo: AbsoluteWebDAVPath(basePath)))
            count = 1
        }
        var iter = rootNode!
        for nextComponent in pathComponents {
            if let next = iter.children[nextComponent] {
                iter = next
            } else {
                iter = Node(name: nextComponent, parent: iter)
                count += 1
            }
        }
        
        return iter
    }
    
    /// Subscript to access a file at a given path. Returns nil if the file does not exist. Setting the file to nil removes the subtree at the given path.
    /// - Parameter pathComponents: The path components of the file.
    /// - Returns: The file at the given path if it exists.
    subscript(_ pathComponents: [String]) -> WebDAVFile? {
        get {
            node(pathComponents: pathComponents)?.file
        } 
        mutating set {
            if let newValue = newValue {
                makeNode(pathComponents: pathComponents).file = newValue
            } else {
                self.removeSubtree(pathComponents)
            }
        }
    }
    
     /// Subscript to access a file at a given path. Returns nil if the file does not exist. Setting the file to nil removes the subtree at the given path.
     /// - Parameter path: The path of the file.
     /// - Returns: The file at the given path if it exists.
    subscript(_ path: WebDAVPath) -> WebDAVFile? {
        get {
            node(pathComponents: path.pathComponents)?.file
        }
        mutating set {
            self[path.pathComponents] = newValue
        }
    }
    
     /// Subscript to access a file at a given path. Returns nil if the file does not exist. Setting the file to nil removes the subtree at the given path.
     /// - Parameter path: The path of the file. Must be below the base path of the tree.
     /// - Returns: The file at the given path if it exists.
    subscript(_ path: any AbsoluteWebDAVPathProtocol) -> WebDAVFile? {
        get throws {
            let relativePath = try path.relative(to: self.basePath)
            return node(pathComponents: relativePath.relativePath.pathComponents)?.file
        }
    }
    
    /// Removes the subtree at a given path. The file at the given path is removed, as well as all its children.
    /// - Parameter pathComponents: The path components of the file to remove.
    mutating func removeSubtree(_ pathComponents: [String]) {
        if pathComponents.isEmpty {
            rootNode = nil
            count = 0
        } else if let node = node(pathComponents: pathComponents) {
            node.parent = nil
            count -= 1
            var iterator = Iterator(index: Index(node: node, index: 0))
            while iterator.next() != nil {
                count -= 1
            }
        }
    }
    
    /// Removes the subtree at a given path. The file at the given path is removed, as well as all its children.
    /// - Parameter path: The path of the file to remove.
    mutating func removeSubtree(_ path: WebDAVPath) {
        self.removeSubtree(path.pathComponents)
    }
    
    /// Removes the subtree at a given path. The file at the given path is removed, as well as all its children.
    /// - Parameter path: The path of the file. Must be below the base path of the tree.
    mutating func removeSubtree(_ path: any AbsoluteWebDAVPathProtocol) throws {
        let relativePath = try path.relative(to: self.basePath)
        
        self.removeSubtree(relativePath.relativePath)
    }
    
    /// Inserts a file into the tree. The file is inserted at its path. If a file already exists at that path, it is replaced.
    /// - Parameter file: The file to insert. The file must be below the base path of the tree.
    mutating func insert(_ file: WebDAVFile) throws {
        let relativePath = try file.path.relative(to: self.basePath)
        self[relativePath.relativePath] = file
    }
}

extension WebDAVFileTree: Collection {
    typealias Element = WebDAVFile
    
    /// An index in the tree. The index is based on a DFS traversal of the tree.
    struct Index: Comparable {
        /// The node at the index.
        fileprivate let node: Node?

        /// The index of the node in the DFS traversal. Used for comparison between indices.
        let index: Int
        
        static func < (lhs: WebDAVFileTree.Index, rhs: WebDAVFileTree.Index) -> Bool {
            lhs.index < rhs.index
        }
        
        static func == (lhs: WebDAVFileTree.Index, rhs: WebDAVFileTree.Index) -> Bool {
            lhs.node === rhs.node
        }
        
        /// Creates a new index with a given node and index.
        fileprivate init(node: Node?, index: Int) {
            self.node = node
            self.index = index
        }
        
        /// Returns the index of the next node in the DFS traversal. Returns nil if there is no next node.
        /// - Note: The order of the files is not guaranteed to be stable being in DFS order.
        /// - Returns: The index of the next node in the DFS traversal. If there is no next node, returns nil.
        func next() -> Index? {
            guard let node = node else {
                return nil
            }
            
            // If the node has children, the next node is the first child.
            if let firstChild = node.children.first {
                return Index(node: firstChild.value, index: index + 1)
            }

            // If the node has no children, the next node is the next sibling (on the 'right'). If there is no next sibling, the next node is the parent's next sibling, and so on. If there is no next sibling (or grandparent's next sibling and so on) the traversal is completed and nil is returned.
            var iter: Node = node
            
            while let parent = iter.parent {
                
                let nextChildIndex =  parent.children.index(after: parent.children.index(forKey: iter.name)!)
                if nextChildIndex < parent.children.endIndex {
                    return Index(node: parent.children[nextChildIndex].value, index: index + 1)
                } else {
                    iter = parent
                }
            }
            
            return nil
        }
    }
    
    /// An iterator for the tree. The iterator traverses the tree in DFS order.
    /// - Note: The order of the files is not guaranteed to be stable beyond being in DFS order.
    struct Iterator: IteratorProtocol {
        private var index: Index
        
        fileprivate init(index: Index) {
            self.index = index
        }
        
        /// Returns the next file in the tree. Returns nil if there is no next file. 
        /// - Note: The order of the files is not guaranteed to be stable being in DFS order.
        /// - Returns: The next file in the tree. If there is no next file, returns nil.
        mutating func next() -> WebDAVFile? {
            guard let nextIndex = index.next() else { return nil }
            index = nextIndex
            return index.node?.file
        }
    }
    
    /// The start index of the tree. The start index is at the base path of the tree.
    var startIndex: Index {
        return .init(node: rootNode, index: 0)
    }
    
    /// The end index of the tree. The end index is the index after the last file.
    var endIndex: Index {
        return .init(node: nil, index: count)
    }
    
    /// Returns an iterator for the tree. The iterator traverses the tree in DFS order.
    /// - Note: The order of the files is not guaranteed to be stable beyond being in DFS order.
    func makeIterator() -> Iterator {
        return Iterator(index: startIndex)
    }
    
    /// Returns the index after a given index. Returns endIndex if there is no index after the given index.
    func index(after i: Index) -> Index {
        guard i != endIndex else {
            fatalError("No index after endIndex")
        }
        
        return i.next() ?? endIndex
    }
    
    subscript(position: Index) -> WebDAVFile {
        position.node!.file
    }
    
    subscript(bounds: Range<Index>) -> Slice<WebDAVFileTree> {
        .init(base: self, bounds: bounds)
    }
}

extension WebDAVFileTree {
    /// Creates a new file tree with a given base path and files.
    /// - Parameters: files: The files to insert into the tree. The files must be below the base path of the tree.
    /// - Parameters: basePath: The base path of the tree. All files in the tree are below this path.
    init(_ files: [WebDAVFile], basePath: any AbsoluteWebDAVPathProtocol) throws {
        self = .init(basePath: basePath)
        for file in files {
            try self.insert(file)
        }
    }
}
