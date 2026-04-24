//
//  ProfileViewController.swift
//  ImageFeed
//
//
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController{
    private var nameLabel: UILabel?
    private var usernameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var imageView: UIImageView?
    private var uiButton: UIButton?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService = ProfileService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypBlack)
        setImageView()
        setLabel()
        setUsernameLabel()
        setDescription()
        setButton()
        
        if let profile = profileService.profile{
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let imageView,
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        
        imageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(view.traitCollection.displayScale),
                .cacheOriginalImage,
                .forceRefresh
            ]){ result in
                switch result{
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                    
                case .failure(let error):
                    print(error)
                }
                
            }
    }
    
    private func updateProfileDetails(profile: Profile){
        nameLabel?.text = profile.name
        usernameLabel?.text = profile.loginName
        descriptionLabel?.text = profile.bio ?? ""
    }
    
    private func setImageView(){
        let imageView = UIImageView()
        self.imageView = imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
    }
    
    private func setLabel(){
        guard let imageView = imageView else { return }
        let namelabel = UILabel()
        namelabel.textColor = .ypWhiteIOS
        namelabel.font = .boldSystemFont(ofSize: 23)
        self.nameLabel = namelabel
        namelabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(namelabel)
        namelabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        namelabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        namelabel.widthAnchor.constraint(equalToConstant: 241).isActive = true
    }
    
    private func setUsernameLabel(){
        guard
            let imageView = imageView,
            let nameLabel = nameLabel else { return }
        let usernameLabel = UILabel()
        usernameLabel.textColor = UIColor(
            red: 174/255,
            green: 175/255,
            blue: 180/255,
            alpha: 1
        )
        usernameLabel.font = .systemFont(ofSize: 13)
        self.usernameLabel = usernameLabel
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameLabel)
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.widthAnchor.constraint(equalToConstant: 99)
        ])
    }
    
    private func setDescription(){
        guard let imageView = imageView else { return }
        guard let usernameLabel = usernameLabel else { return }
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .ypWhiteIOS
        descriptionLabel.font = .systemFont(ofSize: 13)
        self.descriptionLabel = descriptionLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.widthAnchor.constraint(equalToConstant: 77).isActive = true
    }
    
    private func setButton(){
        guard let imageView = imageView else { return }
        let uiButton = UIButton.systemButton(
            with: UIImage(named: "Logout_button")!.withRenderingMode(.alwaysOriginal),
            target: self,
            action: #selector(self.didTapButton))
        self.uiButton = uiButton
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(uiButton)
        uiButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        uiButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        uiButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uiButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    @objc
    private func didTapButton(){
        
    }
}

