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
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.configure(presenter)
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
}
