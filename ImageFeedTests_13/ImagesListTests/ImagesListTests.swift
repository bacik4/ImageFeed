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
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        
        viewController.configure(presenter)
        
        //when
        viewController.loadViewIfNeeded()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    @MainActor
    func testViewControllerCallsPresenterDidReachLastCell() {
        //given
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
        
        // then
        XCTAssertTrue(presenter.didReachLastCellCalled)
    }
    
    @MainActor
    func testViewControllerDoesNotCallPresenterDidReachLastCellWhenCellIsNotLast() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        presenter.photosCountValue = 2

        viewController.configure(presenter)
        viewController.loadViewIfNeeded()

        // when
        viewController.tableView(
            UITableView(),
            willDisplay: UITableViewCell(),
            forRowAt: IndexPath(row: 0, section: 0)
        )

        // then
        XCTAssertFalse(presenter.didReachLastCellCalled)
    }
    
    @MainActor
    func testPresenterSpyRecordsDidTapLike() {
        // given
        let presenter = ImagesListPresenterSpy()
        let indexPath = IndexPath(row: 0, section: 0)
        
        // when
        presenter.didTapLike(at: indexPath)
        
        // then
        XCTAssertTrue(presenter.didTapLikeCalled)
        XCTAssertEqual(presenter.didTapLikeIndexPath, indexPath)
    }
}
