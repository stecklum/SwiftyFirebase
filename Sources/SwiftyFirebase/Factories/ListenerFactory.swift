//
//  ListenerFactory.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import FirebaseFirestore

/**
 A factory class responsible for creating instances of `FirestoreListener`.
 
 This class provides a static method to instantiate a `FirestoreListener` for a given `FirestoreEntity` type.
 */
public final class ListenerFactory {
    
    /**
     Creates a new `FirestoreListener` instance with the specified filter.
     
     - Parameter filter: The filter used to query Firestore for entities.
     - Returns: A `FirestoreListener` instance configured with the given filter.
     */
    public static func create<T: FirestoreEntity>(withFilter filter: Filter) -> FirestoreListener<T> {
        FirestoreListener<T>(filter: filter)
    }
}
