//
//  AppDelegate.swift
//  ImageFeed
//
//
import ProgressHUD
import UIKit
import SwiftUI

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupProgressHUD()
        return true
    }
    
    // MARK: - Private Methods

    private func setupProgressHUD() {
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = Color.white
        ProgressHUD.colorAnimation = Color.black
    }

    // MARK: UISceneSession Lifecycle

    func application(
       _ application: UIApplication,
       configurationForConnecting connectingSceneSession: UISceneSession,
       options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
       let sceneConfiguration = UISceneConfiguration(
           name: "Main",
           sessionRole: connectingSceneSession.role
       )
       sceneConfiguration.delegateClass = SceneDelegate.self
       return sceneConfiguration
    }
}

