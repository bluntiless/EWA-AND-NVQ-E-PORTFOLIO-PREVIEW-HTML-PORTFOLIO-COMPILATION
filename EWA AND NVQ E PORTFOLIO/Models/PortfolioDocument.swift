import UniformTypeIdentifiers
import SwiftUI

extension UTType {
    static var portfolio: UTType {
        UTType(exportedAs: "com.ewa.portfolio", conformingTo: .data)
    }
}

struct PortfolioDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.portfolio] }
    let initialDirectory: String
    
    init(initialDirectory: String) {
        self.initialDirectory = initialDirectory
    }
    
    init(configuration: ReadConfiguration) throws {
        self.initialDirectory = ""
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let wrapper = FileWrapper(directoryWithFileWrappers: [:])
        wrapper.preferredFilename = initialDirectory
        return wrapper
    }
} 