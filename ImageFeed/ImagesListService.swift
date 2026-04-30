//
//  ImagesListService.swift
//  ImageFeed
//
import Foundation
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable{
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

final class ImagesListService {
    private(set) var photos: [Photo] = []
    static let shared = ImagesListService()
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init(){}
    
    func fetchPhotosNextPage() {
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let token = tokenStorage.token else {
            print("[ImagesListService.fetchPhotosNextPage]: token is nil")
            return
        }
        
        guard let request = makePhotosRequest(token: token, page: nextPage) else {
            print("[ImagesListService.fetchPhotosNextPage]: failed to make request")
            return
        }
        
        let task = urlSession.objectTask(for: request){ [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else {return}
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map{ self.makePhoto(from: $0) }
                
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                self.task = nil
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
                
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: \(error)")
                self.task = nil
            }
        }
        self.task = task
        task.resume()
        
    }
    
    func resetPhotos(){
        photos = []
        lastLoadedPage = nil
        task?.cancel()
        task = nil
    }
    
    private func makePhoto(from photoResult: PhotoResult) -> Photo {
        Photo(
            id: photoResult.id,
            size: CGSize(width: photoResult.width, height: photoResult.height),
            createdAt: ISO8601DateFormatter().date(from: photoResult.createdAt),
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.thumb,
            largeImageURL: photoResult.urls.full,
            isLiked: photoResult.likedByUser
        )
    }
    
    private func makePhotosRequest(token: String, page: Int) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)") else{
            print("[ImagesListService.makePhotosRequest]")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void){
        guard let token = tokenStorage.token else {
            print("[ImagesListService.changeLike]: token is nil")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        guard let request = makeChangeLikeRequest(photoId: photoId,isLike: isLike,token: token) else {
            print("[ImagesListService.changeLike]: failed to make request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) {[weak self] result in
            guard let self else {return}
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    }
                    completion(.success(()))
                }
                
            case .failure(let error):
                print("[ImagesListService.changeLike]: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
        
    }
    
    private func makeChangeLikeRequest(photoId: String, isLike: Bool, token: String
    ) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            print("[ImagesListService.makeChangeLikeRequest]: failed to make url")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
