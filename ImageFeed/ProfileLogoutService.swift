//
//  ProfileLogoutService.swift
//  ImageFeed
//
import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        deleteToken()
        cleanServices()
    }
    
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

