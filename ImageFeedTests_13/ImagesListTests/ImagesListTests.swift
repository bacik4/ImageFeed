//
//  ImagesListTests.swift
//  ImageFeed
//
@testable import ImageFeed
import UIKit
import XCTest
import Foundation

final class ImagesListTests: XCTestCase {
    
    @MainActor
    func testViewControllerCallsPresenterViewDidLoad() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        
        viewController.configure(presenter)
        
        // When
        viewController.loadViewIfNeeded()
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    @MainActor
    func testViewControllerCallsPresenterDidReachLastCell() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        presenter.photosCountValue = 1
        
        viewController.configure(presenter)
        viewController.loadViewIfNeeded()
        
        let tableView = UITableView()
        viewController.tableView(
            tableView,
            willDisplay: UITableViewCell(),
            forRowAt: IndexPath(row: 0, section: 0)
        )
        
        // Then
        XCTAssertTrue(presenter.didReachLastCellCalled)
    }
    
    @MainActor
    func testViewControllerDoesNotCallPresenterDidReachLastCellWhenCellIsNotLast() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        presenter.photosCountValue = 2

        viewController.configure(presenter)
        viewController.loadViewIfNeeded()

        // When
        viewController.tableView(
            UITableView(),
            willDisplay: UITableViewCell(),
            forRowAt: IndexPath(row: 0, section: 0)
        )

        // Then
        XCTAssertFalse(presenter.didReachLastCellCalled)
    }
    
    @MainActor
    func testPresenterSpyRecordsDidTapLike() {
        // Given
        let presenter = ImagesListPresenterSpy()
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        presenter.didTapLike(at: indexPath)
        
        // Then
        XCTAssertTrue(presenter.didTapLikeCalled)
        XCTAssertEqual(presenter.didTapLikeIndexPath, indexPath)
    }
}
