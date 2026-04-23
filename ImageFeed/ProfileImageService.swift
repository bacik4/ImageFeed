//
//  ProfileImageService.swift
//  ImageFeed
//
import Foundation

struct ProfileImage: Codable{
    let small: String
    let medium: String
    let large: String
}

struct UserResult: Codable{
    let profileImage: ProfileImage
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService{
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private init() {}
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else{
            print("[ProfileImageService.fetchProfileImageURL]: missingToken - username: \(username)")
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else{
            print("[ProfileImageService.fetchProfileImageURL]: invalidRequest - failed to create request, username: \(username)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request){ [weak self] (result: Result<UserResult,Error>) in
            guard let self else {return}
            defer{self.task = nil}
            
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: error - \(error.localizedDescription), username: \(username)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else{
            print("[ProfileImageService.makeProfileImageRequest]: invalidURL - token: \(token)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


