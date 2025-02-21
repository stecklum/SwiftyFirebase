//
//  FirestoreManagerFactory.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

public class FirestoreManagerFactory {
    static func create<T: FirestoreEntity>() -> FirestoreManager<T> {
        FirestoreManager<T>(collection: T.collection)
    }
}
