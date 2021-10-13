import Foundation

public enum PurchasesError: Error {
    case unknown
    case productsFetchError
    case invalidOffering
    case noCurrentOffering
}
