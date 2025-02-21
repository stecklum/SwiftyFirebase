//
//  CloudStorageManager.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import Foundation
import Firebase

struct CloudStorageManager {
    
    private var storage
    
    init(storage: Storage = Storage.storage()) {
        self.storage = storage
    }
    
    private func uploadData(_ data: Data, to path: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let storageRef = storage.reference().child(path)

        storageRef.putData(data) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            } else {
                completion(.success(storageRef.fullPath))
            }
        }
    }
    
    func uploadData(_ data: Data, to path: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            uploadData(data, to: path) { result in
                switch result {
                case .success(let path):
                    continuation.resume(returning: path)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func fetchData(from path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let storageRef = storage.reference().child(path)

        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }
    }
    
    func fetchData(from path: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            fetchData(from: path) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
