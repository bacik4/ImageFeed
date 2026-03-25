//
//  ProfileViewController.swift
//  ImageFeed
//
//
import UIKit

final class ProfileViewController: UIViewController{
    private var namelabel: UILabel?
    private var usernameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var imageView: UIImageView?
    private var uiButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageView()
        setLabel()
        setUsernameLabel()
        setDescription()
        setButton()
    }
    
    private func setImageView(){
        let profileImage = UIImage(named: "Avatar")
        let imageView = UIImageView(image: profileImage)
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
        namelabel.text = "Екатерина Новикова"
        namelabel.textColor = .ypWhiteIOS
        namelabel.font = .boldSystemFont(ofSize: 23)
        self.namelabel = namelabel
        namelabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(namelabel)
        namelabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        namelabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        namelabel.widthAnchor.constraint(equalToConstant: 241).isActive = true
    }
    
    private func setUsernameLabel(){
        guard let imageView = imageView else { return }
        guard let namelabel = namelabel else { return }
        let usernameLabel = UILabel()
        usernameLabel.text = "@ekaterina_nov"
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
        usernameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: namelabel.bottomAnchor, constant: 8).isActive = true
        usernameLabel.widthAnchor.constraint(equalToConstant: 99).isActive = true
    }
    
    private func setDescription(){
        guard let imageView = imageView else { return }
        guard let usernameLabel = usernameLabel else { return }
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
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

