//
//  Plugin.swift
//  
//
//  Created by Tim Brooks on 6/17/22.
//

import Foundation
import PackagePlugin

@main
struct ShowTodos: CommandPlugin {

    // MARK: - Properties
    private let defaultTokens = ["TODO", "FIXME", "HACK"]
    private let patternFormat = #"\/\/(?: ?|\t?)(?:%@)(?:\:?|\ ?)(.*$)"#
    
    // MARK: - API
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        
        for target in context.package.targets {
            
            guard let target = target as? SourceModuleTarget else { continue }
            let sourceFileList = target.sourceFiles(withSuffix: ".swift")
            let sourceFiles = sourceFileList.map(\.path)

            try processSourceFiles(sourceFiles)
        }
    }
    
    // MARK: - File Processing
    private func processSourceFiles(_ paths: [Path]) throws {
        
        // Create the regex
        let tokenPattern = self.defaultTokens.joined(separator: "|")
        let searchPattern = String(format: self.patternFormat, tokenPattern)
        let regex = try NSRegularExpression(pattern: searchPattern, options: [.anchorsMatchLines, .caseInsensitive])
        
        for path in paths {

            // TODO: Switch to macOS 13 method
            let sourceFileURL = URL(fileURLWithPath: path.string)
            let data = try Data(contentsOf: sourceFileURL)
            let source = String(data: data, encoding: .utf8)
            
            if let source {

                // Process
                for result in processRegex(regex, source: source).flatMap({ $0 }) {
                    Diagnostics.remark("☐ \(result.trimmingCharacters(in: .whitespacesAndNewlines)) {\(path.lastComponent)}")
                }
            }
        }
    }
    
    // MARK: - Regex Processing
    private func processRegex(_ regex: NSRegularExpression, source: String) -> [[String]] {
     
        let stringRange = NSRange(location: 0, length: source.utf16.count)
        let matches = regex.matches(in: source, range: stringRange)
        var result: [[String]] = []
        
        for match in matches {
        
            var groups: [String] = []
            for rangeIndex in 1 ..< match.numberOfRanges {
                let nsRange = match.range(at: rangeIndex)
                guard !NSEqualRanges(nsRange, NSMakeRange(NSNotFound, 0)) else { continue }
                let string = (source as NSString).substring(with: nsRange)
                groups.append(string)
            }
            
            if !groups.isEmpty {
                result.append(groups)
            }
        }
        
        return result
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension ShowTodos: XcodeCommandPlugin {

    /// 👇 This entry point is called when operating on an Xcode project.
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
       print("Command plugin execution for Xcode project \(context.xcodeProject.displayName)")
        
        for target in context.xcodeProject.targets {

            let sourceFiles = target.inputFiles.filter({ $0.path.lastComponent.contains(".swift") }).map(\.path)
            try processSourceFiles(sourceFiles)
        }
    }
}
#endif

