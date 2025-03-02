//
//  FirestoreManagerFactory.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

/**
 A factory class responsible for creating instances of `FirestoreManager`.
 
 This class provides a static method to instantiate a `FirestoreManager` for a given `FirestoreEntity` type.
 */
public final class FirestoreManagerFactory {
    /**
     Creates a new `FirestoreManager` instance for the specified entity type.
     
     - Returns: A `FirestoreManager` instance configured for the given entity type.
     */
    public static func create<T: FirestoreEntity>() -> FirestoreManager<T> {
        FirestoreManager<T>(collection: T.collection)
    }
}
