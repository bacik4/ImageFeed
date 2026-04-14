//
//  URLSession+data.swift
//  ImageFeed
//
//
import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<(Data, HTTPURLResponse), Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let error{
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }

            guard let data,
                  let response = response as? HTTPURLResponse else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }

            fulfillCompletionOnTheMainThread(.success((data, response)))
        }

        return task
    }
}
