//
//  ImagesListPresenter.swift
//  ImageFeed
//
import Foundation
import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? {get set}
    
    func viewDidLoad()
    func didReachLastCell()
    func didTapLike(at indexPath: IndexPath)
    
    func photosCount() -> Int
    func photo(at indexPath: IndexPath) -> Photo
    
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photosCountBeforeUpdate = 0
    
    deinit {
        if let imagesListServiceObserver {
            NotificationCenter.default.removeObserver(imagesListServiceObserver)
        }
    }
    
    func viewDidLoad() {
        photosCountBeforeUpdate = imagesListService.photos.count
        
        setupImagesObserver()
        fetchNextPage()
    }
    
    private func setupImagesObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            
            let oldCount = self.photosCountBeforeUpdate
            let newCount = self.imagesListService.photos.count
            
            self.photosCountBeforeUpdate = newCount
            self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
    
    private func fetchNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func didReachLastCell() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func photosCount() -> Int {
        imagesListService.photos.count
    }

    func photo(at indexPath: IndexPath) -> Photo {
        imagesListService.photos[indexPath.row]
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        let newIsLiked = !photo.isLiked

        view?.showLoading()

        imagesListService.changeLike(photoId: photo.id, isLike: newIsLiked) { [weak self] result in
            guard let self else { return }

            self.view?.hideLoading()

            switch result {
            case .success:
                self.view?.setLike(isLiked: newIsLiked, at: indexPath)

            case .failure:
                self.view?.setLike(isLiked: photo.isLiked, at: indexPath)
            }
        }
    }
}
