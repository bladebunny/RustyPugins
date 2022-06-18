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
        
        print("...running showtodos...")
    }
}
