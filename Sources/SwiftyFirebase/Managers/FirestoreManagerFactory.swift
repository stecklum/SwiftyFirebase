//
//  FirestoreManagerFactory.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

public class FirestoreManagerFactory {
    public static func create<T: FirestoreEntity>() -> FirestoreManager<T> {
        FirestoreManager<T>(collection: T.collection)
    }
}
