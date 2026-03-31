//
//  LoginViewController.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = LoginViewModel()
    
    // MARK: - UI Components
    private let containerView = UIView()
    
    private let logoIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "briefcase.fill")
        iv.tintColor = UIColor(red: 0.18, green: 0.24, blue: 0.45, alpha: 1.0)
        return iv
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Register Offline"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.18, green: 0.24, blue: 0.45, alpha: 1.0)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Masuk ke Akun Verifikator"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .darkGray
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Masukkan email dan password untuk masuk"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let emailTextField = CustomTextField(title: "Email *", placeholder: "Masukkan email di sini")
    private let passwordTextField = CustomTextField(title: "Password", placeholder: "Masukkan password", isSecure: true)
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Login", for: .normal)
        btn.backgroundColor = UIColor.lightGray
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.isEnabled = false
        return btn
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        let fullText = "Belum punya akun? Daftar disini"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: (fullText as NSString).range(of: "Daftar disini"))
        label.attributedText = attributedString
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(containerView)
        view.addSubview(footerLabel)
        
        containerView.addSubview(logoIcon)
        containerView.addSubview(headerLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        containerView.addSubview(loginButton)
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.left.right.equalToSuperview().inset(24)
        }
        
        logoIcon.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.size.equalTo(24)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(logoIcon)
            make.left.equalTo(logoIcon.snp.right).offset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoIcon.snp.bottom).offset(32)
            make.left.right.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.left.right.equalToSuperview()
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(32)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        
        footerLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
        }
    }

    private func setupBindings() {
        
        let input = LoginViewModel.Input(
            email: emailTextField.textField.rx.text.orEmpty.asObservable(),
            password: passwordTextField.textField.rx.text.orEmpty.asObservable(),
            loginTap: loginButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isButtonEnabled
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.isButtonEnabled
            .subscribe(onNext: { [weak self] isValid in
                self?.loginButton.backgroundColor = isValid ? UIColor(red: 0.18, green: 0.24, blue: 0.45, alpha: 1.0) : UIColor.lightGray
            })
            .disposed(by: disposeBag)
        
        // LOADING
        output.loading
            .subscribe(onNext: { isLoading in
                print("Loading: \(isLoading)")
            })
            .disposed(by: disposeBag)
        
        // SUCCESS
        output.loginSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let vc = HomeViewController()
                self?.navigationController?.setViewControllers([vc], animated: true)
            })
            .disposed(by: disposeBag)
        
        // ERROR
        output.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer()
        footerLabel.isUserInteractionEnabled = true
        footerLabel.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                let vc = SignupViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
