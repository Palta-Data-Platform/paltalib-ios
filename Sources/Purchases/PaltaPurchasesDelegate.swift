//
//  PaltaPurchasesDelegate.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 09/06/2022.
//

import Foundation

public protocol PaltaPurchasesDelegate: AnyObject {
    func paltaPurchases(_ purchases: PaltaPurchases, needsToOpenURL: URL, completion: @escaping () -> Void)
}
