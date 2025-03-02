//
//  CloudStorageManager.swift
//  
//
//  Created by Tom Stecklum on 21.02.25.
//

import FirebaseStorage
import Foundation

/**
 A class responsible for managing file storage operations in Firebase Cloud Storage.

 This class provides methods to upload and retrieve files asynchronously.
 */
public final class CloudStorageManager {
    
    /// The Firebase Storage instance used for file operations.
    private var storage: Storage

    /**
     Initializes a new `CloudStorageManager` instance.

     - Parameter storage: The Firebase Storage instance to use. Defaults to `Storage.storage()`.
     */
    public init(storage: Storage = Storage.storage()) {
        self.storage = storage
    }

    /**
     Uploads data to Firebase Cloud Storage.

     - Parameter data: The binary data to be uploaded.
     - Parameter path: The path where the data should be stored.
     - Parameter completion: A closure that returns either the full path of the stored file or an error if the upload fails.
     */
    private func uploadData(_ data: Data, to path: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storageRef = storage.reference().child(path)

        storageRef.putData(data) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(storageRef.fullPath))
            }
        }
    }

    /**
     Uploads data to Firebase Cloud Storage asynchronously.

     This method wraps `uploadData(_:to:completion:)` inside a Swift concurrency continuation,
     allowing it to be used with `async/await`.

     - Parameter data: The binary data to be uploaded.
     - Parameter path: The path where the data should be stored.
     - Throws: An error if the upload operation fails.
     - Returns: The full path of the stored file.
     */
    public func uploadData(_ data: Data, to path: String) async throws -> String {
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

    /**
     Fetches data from Firebase Cloud Storage.

     - Parameter path: The path of the file to be retrieved.
     - Parameter completion: A closure that returns either the downloaded data or an error if the operation fails.
     */
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

    /**
     Fetches data from Firebase Cloud Storage asynchronously.

     This method wraps `fetchData(from:completion:)` inside a Swift concurrency continuation,
     allowing it to be used with `async/await`.

     - Parameter path: The path of the file to be retrieved.
     - Throws: An error if the download operation fails.
     - Returns: The downloaded file data.
     */
    public func fetchData(from path: String) async throws -> Data {
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
