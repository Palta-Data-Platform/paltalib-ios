//
//  PaltaAnalytics+Context.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation

public extension PaltaAnalytics {
    func _editContext<C: BatchContext>(_ modifier: (inout C) -> Void) {
        assembly.eventQueueAssembly.contextModifier.editContext(modifier)
    }
}
