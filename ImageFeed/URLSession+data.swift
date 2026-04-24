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
            if let error {
                print("[URLSession.data]: urlRequestError - \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }

            guard let data,
                  let response = response as? HTTPURLResponse else {
                print("[URLSession.data]: urlSessionError - response or data is nil")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }

            fulfillCompletionOnTheMainThread(.success((data, response)))
        }

        return task
    }

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()

        let task = data(for: request) { (result: Result<(Data, HTTPURLResponse), Error>) in
            switch result {
            case .success(let (data, response)):
                guard 200..<300 ~= response.statusCode else {
                    print("[URLSession.objectTask]: httpStatusCode - \(response.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                    return
                }

                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("[URLSession.objectTask]: decodingError - \(error.localizedDescription), data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }

            case .failure(let error):
                print("[URLSession.objectTask]: requestError - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        return task
    }
}
