//
//  FirestoreEntity.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import Foundation
import FirebaseFirestore

public protocol FirestoreEntity: Identifiable, Codable, Hashable {
    var id: String? { get set }
    static var collection: FirestoreCollection { get }
}
