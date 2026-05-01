//
//  ProfileLogoutService.swift
//  ImageFeed
//
import Foundation
import WebKit

// MARK: - ProfileLogoutService

final class ProfileLogoutService {
    // MARK: - Singleton
    
    static let shared = ProfileLogoutService()

    private init() { }
    
    // MARK: - Public Methods
    
    func logout() {
        cleanCookies()
        deleteToken()
        cleanServices()
    }
    
    // MARK: - Private Methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func deleteToken(){
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func cleanServices(){
        ProfileService.shared.resetProfile()
        ProfileImageService.shared.resetAvatarURL()
        ImagesListService.shared.resetPhotos()
    }
}

