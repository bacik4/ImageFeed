//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//

import UIKit
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var didReachLastCellCalled = false
    
    var photosCountValue = 1
    
    var didTapLikeCalled = false
    var didTapLikeIndexPath: IndexPath?
    
    var photos: [Photo] = [
        Photo(
            id: "test_id",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: "Test description",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: false
        )
    ]
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didReachLastCell() {
        didReachLastCellCalled = true
    }
    
    func photosCount() -> Int {
        photosCountValue
    }

    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
    
    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
        didTapLikeIndexPath = indexPath
    }
}
