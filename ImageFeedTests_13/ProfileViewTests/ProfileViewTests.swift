//
//  ProfileViewTests.swift
//  ImageFeed
//
@testable import ImageFeed
import UIKit
import XCTest
import Foundation

final class ProfileViewTests: XCTestCase {
    
    @MainActor
    func testViewControllerCallsPresenterViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.configure(presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
}
