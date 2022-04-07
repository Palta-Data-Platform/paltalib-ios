//
//  HTTPClientMock.swift
//  PaltaLibAnalytics
//
//  Created by Vyacheslav Beltyukov on 07.04.2022.
//

import Foundation
import PaltaLibCore

final class HTTPClientMock: HTTPClient {
    var request: HTTPRequest?
    var result: Result<Any, Error>?

    func perform<T>(_ request: HTTPRequest, with completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        self.request = request

        completion(
            result?.map { $0 as! T } ?? .failure(NSError())
        )
    }
}
