//
//  FirestoreCollection.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

/**
 A protocol representing a Firestore collection.
 
 Conforming types must provide a raw string value that represents the collection name in Firestore.
 */
public protocol FirestoreCollection {
    /// The string representation of the Firestore collection name.
    var rawValue: String { get }
}
