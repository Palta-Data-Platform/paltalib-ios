//
//  BatchSendController.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation

protocol BatchSendController {
    var isReady: Bool { get }
    var isReadyCallback: (() -> Void)? { get set }
    
    func sendBatch(of events: [BatchEvent])
}
