//
//  ProfileService.swift
//  ImageFeed
//
import Foundation

struct Profile{
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Codable{
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

final class ProfileService {
    static let shared = ProfileService()
    
    private init() {}
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void){
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: invalidRequest - failed to create request, token: \(token)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request){[weak self] (result: Result<ProfileResult, Error>) in
            guard let self else {return}
            
            defer { self.task = nil }
            
            switch result{
            case .success(let profileResult):
                let profile = Profile(
                        username: profileResult.username,
                        name: "\(profileResult.firstName) \(profileResult.lastName ?? "")"
                            .trimmingCharacters(in: .whitespaces),
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio
                    )
                    
                    self.profile = profile
                    completion(.success(profile))
                
            case .failure(let error):
                print("[ProfileService.fetchProfile]: error - \(error.localizedDescription), token: \(token)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else{
            print("[ProfileService.makeProfileRequest]: invalidURL - token: \(token)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
