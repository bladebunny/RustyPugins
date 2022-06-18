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
            
            for file in sourceFiles {
                Diagnostics.remark("Processing: \(file.lastComponent)")
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
    }
}
#endif
