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
            Diagnostics.remark("Inspecting target: \(target.name)")
        }
    }
}
