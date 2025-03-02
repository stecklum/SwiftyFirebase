//
//  FirestoreEntity.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

/**
 A protocol representing an entity that can be stored in Firestore.
 
 Conforming types must be identifiable, codable, hashable, and sendable.
 They must also specify their associated Firestore collection.
 */
public protocol FirestoreEntity: Identifiable, Codable, Hashable, Sendable {
    /// The unique identifier of the Firestore entity.
    var id: String? { get set }
    
    /// The Firestore collection associated with the entity.
    static var collection: FirestoreCollection { get }
}
