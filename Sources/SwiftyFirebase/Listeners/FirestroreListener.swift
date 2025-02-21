//
//  FirestroreListener.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import FirebaseFirestore
import Foundation

@Observable
public class FirestoreListener<Entity: FirestoreEntity> {
    
    private var firestore: Firestore
    public var objects: [Entity] = []
    public var listenerRegistration: ListenerRegistration?
    public var errorMessage: String?
    
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
    
    deinit {
        listenerRegistration?.remove()
    }
    
}
