//
//  FirestoreRepositoryFactory.swift
//  SwiftyFirebase
//
//  Created by Tom Stecklum on 02.03.25.
//
/**
 A factory class responsible for creating instances of `FirestoreRepository`.
 
 This class provides a static method to instantiate a `FirestoreRepository` for a given `FirestoreEntity` type.
 */
public final class FirestoreRepositoryFactory {
    
    /**
     Creates a new `FirestoreRepository` instance for the specified entity type.
     
     - Returns: A `FirestoreRepository` instance configured for the given entity type.
     */
    public static func create<T: FirestoreEntity, R: FirestoreRepository>() -> R where R.Entity == T {
        return R(manager: FirestoreManagerFactory.create())
    }
}
