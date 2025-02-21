//
//  ListenerFactory.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import Foundation
import FirebaseFirestore

public class ListenerFactory {
    static func create<T: FirestoreEntity>(forType type: T.Type, withFilter filter: Filter) -> FirestoreListener<T> {
        return FirestoreListener<T>(filter: filter)
    }
}
