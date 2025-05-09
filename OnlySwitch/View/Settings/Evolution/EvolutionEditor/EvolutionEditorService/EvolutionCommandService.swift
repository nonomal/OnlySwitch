//
//  EvolutionEditorService.swift
//  OnlySwitch
//
//  Created by Jacklandrin on 2023/5/27.
//

import Foundation

struct EvolutionCommandService {
    var executeCommand: @Sendable (EvolutionCommand?) async throws -> String
    var saveCommand: @Sendable (EvolutionItem) async throws -> Void
    var saveIcon: @Sendable (UUID, String) async throws -> Void
}
