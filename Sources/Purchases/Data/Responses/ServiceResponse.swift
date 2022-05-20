//
//  ServiceResponse.swift
//  PaltaLibPayments
//
//  Created by Vyacheslav Beltyukov on 20/05/2022.
//

import Foundation

struct ServiceResponse: Decodable {
    let services: [Service]
}
