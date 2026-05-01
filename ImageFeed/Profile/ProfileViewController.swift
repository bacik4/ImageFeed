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
    
    private var animationLayers: [CALayer] = []
    
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
        } else{
            addGradientLayers()
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
                self.removeGradientLayers()
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
        guard let imageView else { return }
        let uiButton = UIButton.systemButton(
            with: UIImage(resource: .logoutButton).withRenderingMode(.alwaysOriginal),
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
    
    private func makeGradientLayer(size: CGSize, cornerRadius: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        return gradient
    }
    
    private func addGradientLayers() {
        removeGradientLayers()
        guard
            let imageView,
            let nameLabel,
            let usernameLabel,
            let descriptionLabel
        else { return }
        
        let avatarGradient = makeGradientLayer(
            size: CGSize(width: 70, height: 70),
            cornerRadius: 35
        )
        
        let nameGradient = makeGradientLayer(
            size: CGSize(width: 223, height: 18),
            cornerRadius: 9
        )
        
        let usernameGradient = makeGradientLayer(
            size: CGSize(width: 89, height: 18),
            cornerRadius: 9
        )
        
        let descriptionGradient = makeGradientLayer(
            size: CGSize(width: 67, height: 18),
            cornerRadius: 9
        )
        
        imageView.layer.addSublayer(avatarGradient)
        nameLabel.layer.addSublayer(nameGradient)
        usernameLabel.layer.addSublayer(usernameGradient)
        descriptionLabel.layer.addSublayer(descriptionGradient)
        
        animationLayers = [
            avatarGradient,
            nameGradient,
            usernameGradient,
            descriptionGradient
        ]
    }
    
    private func removeGradientLayers() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    @objc
    private func didTapButton(){
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Да", style: .default){[weak self] _ in
            ProfileLogoutService.shared.logout()
            self?.switchToSplashViewController()
        }
        let no = UIAlertAction(title: "Нет", style: .cancel)

        alert.addAction(yes)
        alert.addAction(no)
        
        present(alert, animated: true)
    }
    
    
    private func switchToSplashViewController() {
        guard let window = view.window else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}

