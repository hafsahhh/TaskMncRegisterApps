//
//  ProfileViewController.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ProfileViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    // MARK: - Data
    private let profile: ProfileResponse
    
    // MARK: - UI Components
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.left", withConfiguration: config), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    private let titleHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "profile")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(red: 0.22, green: 0.30, blue: 0.55, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private let menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "v1.0.1"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Init
    init(profile: ProfileResponse) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        setupUI()
        bindData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        [backButton, titleHeaderLabel, avatarImageView, nameLabel,
         addressLabel, emailLabel, menuStackView, versionLabel].forEach { view.addSubview($0) }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalToSuperview().offset(20)
        }
        
        titleHeaderLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.left.equalTo(backButton.snp.right).offset(12)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(titleHeaderLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        menuStackView.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(35)
            make.left.right.equalToSuperview().inset(20)
        }
        
        versionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        setupMenuSections()
    }
    
    private func setupMenuSections() {
        let changePasswordRow = createMenuRow(icon: "ellipsis.rectangle", title: "Ganti Password")
        let helpRow = createMenuRow(icon: "questionmark.circle", title: "Bantuan")
        let firstSection = createCardContainer(views: [changePasswordRow, createSeparator(), helpRow])
        
        let logoutRow = createMenuRow(icon: "rectangle.portrait.and.arrow.right", title: "Keluar", isDestructive: true)
        let secondSection = createCardContainer(views: [logoutRow])
        
        menuStackView.addArrangedSubview(firstSection)
        menuStackView.addArrangedSubview(secondSection)
        
        logoutRow.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        logoutRow.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .subscribe(onNext: { _ in
                KeychainManager.shared.deleteToken()
                
                if let sceneDelegate = UIApplication.shared.connectedScenes
                    .first?.delegate as? SceneDelegate {
                    
                    let loginVC = LoginViewController()
                    let nav = UINavigationController(rootViewController: loginVC)
                    sceneDelegate.window?.rootViewController = nav
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindData() {
        nameLabel.text = profile.fullName
        emailLabel.text = profile.email
        addressLabel.text = "Menteng, Jakarta Pusat, DKI Jakarta"
    }
    
    // MARK: - UI Helpers
    private func createCardContainer(views: [UIView]) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 0.99, alpha: 1.0)
        container.layer.cornerRadius = 12
        
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 0
        
        container.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(8) }
        
        return container
    }
    
    private func createMenuRow(icon: String, title: String, isDestructive: Bool = false) -> UIView {
        let row = UIView()
        row.snp.makeConstraints { $0.height.equalTo(48) }
        
        let iconImg = UIImageView(image: UIImage(systemName: icon))
        iconImg.tintColor = isDestructive ? .systemRed : .darkGray
        iconImg.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = isDestructive ? .systemRed : .black
        
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .lightGray
        arrow.preferredSymbolConfiguration = .init(pointSize: 12)
        
        [iconImg, label, arrow].forEach { row.addSubview($0) }
        
        iconImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(iconImg.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
        
        arrow.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        return row
    }
    
    private func createSeparator() -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor.systemGray5
        line.snp.makeConstraints { $0.height.equalTo(1) }
        return line
    }
}
