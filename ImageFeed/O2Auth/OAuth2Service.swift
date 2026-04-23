//
//  OAuth2Service.swift
//  ImageFeed
//
//
import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchOAuthToken(code: String,completion: @escaping (Result<String,Error>) -> Void){
        assert(Thread.isMainThread)
        guard lastCode != code else{
            print("[OAuth2Service.fetchOAuthToken]: invalidRequest - duplicate code: \(code)")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code)
        else {
            print("[OAuth2Service.fetchOAuthToken]: invalidRequest - failed to create request, code: \(code)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request){ [weak self] (result:Result<OAuthTokenResponseBody, Error>) in
            guard let self else {return}
            
            self.task = nil
            self.lastCode = nil
            
            switch result {
            case .success(let responseBody):
                self.tokenStorage.token = responseBody.accessToken
                completion(.success(responseBody.accessToken))
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: error - \(error.localizedDescription), code: \(code)")
                completion(.failure(error))
            }
            
    
            }
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else{
            print("[OAuth2Service.makeOAuthTokenRequest]: invalidURLComponents - code: \(code)")
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
            print("[OAuth2Service.makeOAuthTokenRequest]: invalidURL - code: \(code)")
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
