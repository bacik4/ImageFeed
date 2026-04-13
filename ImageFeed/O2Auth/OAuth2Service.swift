//
//  OAuth2Service.swift
//  ImageFeed
//
//
import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage()
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String,Error>) -> Void){
            guard let request = makeOAuthTokenRequest(code: code) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidRequest))
                }
                print("Не удалось создать URLRequest для получения OAuth token")
                return
            }
            let task = URLSession.shared.data(for: request) { result in
                switch result {
                case .success(let (data, response)):
                    guard 200..<300 ~= response.statusCode else {
                        let errorBody = String(data: data, encoding: .utf8) ?? "Не удалось прочитать тело ответа"
                            print("Ошибка Unsplash. Код: \(response.statusCode)")
                            print("Тело ответа: \(errorBody)")
                        DispatchQueue.main.async {
                            completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                        }
                        return
                    }
                    
                    do {
                        let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                        self.tokenStorage.token = responseBody.accessToken
                        DispatchQueue.main.async {
                            completion(.success(responseBody.accessToken))
                        }
                    } catch {
                        print("Ошибка декодирования OAuthTokenResponseBody: \(error)")
                        DispatchQueue.main.async {
                            completion(.failure(NetworkError.decodingError(error)))
                        }
                    }
                    
                case .failure(let error):
                    print("Сетевая ошибка: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else{
            print("Не удалось создать urlComponents для запроса OAuth token")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        guard let authTokenUrl = urlComponents.url else {
            print("Не удалось получить URL для запроса OAuth token")
            return nil
        }
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
