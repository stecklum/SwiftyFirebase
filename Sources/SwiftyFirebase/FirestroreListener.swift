//
//  FirestroreListener.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import Foundation
import FirebaseFirestore

@Observable
public class FirestoreListener<Entity: FirestoreEntity> {
    
    @ObservationIgnored @Injected(\.firestore) private var firestore
    var objects: [Entity] = []
    var listenerRegistration: ListenerRegistration?
    var errorMessage: String?
    
    init(filter: Filter) {
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
