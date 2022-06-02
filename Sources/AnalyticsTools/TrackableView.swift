//
//  TrackableView.swift
//  AnalyticsTools
//
//  Created by Vyacheslav Beltyukov on 01/06/2022.
//

import UIKit

public protocol TrackableView: UIView {
    /// An app-wise unique identifier of the view. Identifier should represent content rather than view instance itself.
    /// For example, you can use user id as an identifier of cell displaying user profile.
    var identifier: AnyHashable { get }
    
    /// All identifiers of view groups this view belongs to. Default implementation returns empty set.
    var groupIdentifiers: Set<AnyHashable> { get }
}

public extension TrackableView {
    var groupIdentifiers: Set<AnyHashable> {
        []
    }
}
