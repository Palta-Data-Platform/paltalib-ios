//
//  PurchasePlugin.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 04.05.2022.
//

import Foundation

public protocol PurchasePlugin {
    func logIn(appUserId: String)
    func logOut()
}
