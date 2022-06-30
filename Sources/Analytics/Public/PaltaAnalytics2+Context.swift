//
//  PaltaAnalytics2+Context.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 30/06/2022.
//

import Foundation

public extension PaltaAnalytics2 {
    func editContext<C: BatchContext>(_ modifier: (inout C) -> Void) {
        assembly.eventQueueAssembly.contextModifier.editContext(modifier)
    }
}
