//
//  ProfilePresenter.swift
//  ImageFeed
//
import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }

    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileService
    
    init(profileService: ProfileService = .shared) {
        self.profileService = profileService
    }
    
    func viewDidLoad() {
        if let profile = profileService.profile{
            view?.updateProfileDetails(profile: profile)
        } else{
            view?.showLoadingSkeleton()
        }
    }
}
