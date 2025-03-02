//
//  FirestroreListener.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import FirebaseFirestore
import Foundation

/**
 A class responsible for listening to Firestore updates for a given entity.
 
 This class observes real-time updates from Firestore based on a provided filter.
 The retrieved objects are stored in `objects`, and any errors are stored in `errorMessage`.
 */
@Observable
public final class FirestoreListener<Entity: FirestoreEntity> {
    /// The Firestore instance used for database access.
    private var firestore: Firestore
    
    /// The list of Firestore entities retrieved from the database.
    public var objects: [Entity] = []
    
    /// The Firestore listener registration, used to manage the real-time update subscription.
    public var listenerRegistration: ListenerRegistration?
    
    /// Stores error messages encountered during Firestore data retrieval.
    public var errorMessage: String?
    
    /**
     Initializes a new FirestoreListener with the given filter.
     
     - Parameter filter: The filter used to query Firestore for entities.
     */
    public init(filter: Filter) {
        firestore = Firestore.firestore()
        listenerRegistration = firestore.collection(Entity.collection.rawValue).whereFilter(filter).addSnapshotListener { [weak self] snapshots, error in
            if let error {
                self?.errorMessage = error.localizedDescription
            } else if let objects = snapshots?.documents.compactMap({ try? $0.data(as: Entity.self) }) {
                self?.objects = objects
            } else {
                self?.errorMessage = "No expenses were found"
            }
        }
    }
    
    /**
     Cleans up the Firestore listener when the instance is deallocated.
     */
    deinit {
        listenerRegistration?.remove()
    }
}
