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

    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {

        for target in context.package.targets {
            
            guard let target = target as? SourceModuleTarget else { continue }
            let sourceFileList = target.sourceFiles(withSuffix: ".swift")
            let sourceFiles = sourceFileList.map(\.path)

            try processSourceFiles(sourceFiles)
        }
    }
    
    private func processSourceFiles(_ paths: [Path]) throws {
        for path in paths {

            if let sourceFileURL = URL(string: path.string) {
                
                let data = try Data(contentsOf: sourceFileURL)
                let source = String(data: data, encoding: .utf8)
                Diagnostics.remark("Processing: \(path.lastComponent): length: \(source?.count ?? 0)")
            }
        }
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

/*
import Foundation

let pattern = #"\/\/(?: ?|\t?)(?:TODO|FIXME)(?:\:?|\ ?)(.*$)"#
let regex = try! NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .caseInsensitive])
let testString = #"""
// TODO switch to host(percentEncoded:) for macOS 13
        if let host = url.host {
            parts.append(URLPart(part: Strings.Serializers.URL.Parts.host, value: host))
            
            let hostParts = host.components(separatedBy: ".")
            if hostParts.count > 2 {
                
                let domain = hostParts.dropFirst().joined(separator: ".")
                parts.append(URLPart(part: Strings.Serializers.URL.Parts.domain, value: domain))
                
                if hostParts[0].lowercased() != "www" {
                    parts.append(URLPart(part: Strings.Serializers.URL.Parts.subDomain, value: hostParts[0]))
                }
            }
        }

"""#
let stringRange = NSRange(location: 0, length: testString.utf16.count)
let matches = regex.matches(in: testString, range: stringRange)
var result: [[String]] = []
for match in matches {
    var groups: [String] = []
    for rangeIndex in 1 ..< match.numberOfRanges {
        let nsRange = match.range(at: rangeIndex)
        guard !NSEqualRanges(nsRange, NSMakeRange(NSNotFound, 0)) else { continue }
        let string = (testString as NSString).substring(with: nsRange)
        groups.append(string)
    }
    if !groups.isEmpty {
        result.append(groups)
    }
}
print(result)
*/
