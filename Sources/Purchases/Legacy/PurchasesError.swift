import Foundation
import PaltaLibCore

public enum PurchasesError: Error {
    case unknown
    case productsFetchError
    case invalidOffering
    case noCurrentOffering
}

public enum WebSubscriptionError: Error {
    case noUserFound
    case networkError(NetworkError)
}
