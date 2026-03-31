//
//  SignupViewController.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SignupViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = SignupViewModel()
    
    // MARK: - UI (SAMA SEPERTI LOGIN)
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
        label.text = "Daftar Akun Verifikator"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .darkGray
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Lengkapi data untuk membuat akun"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - FORM
    private let emailTF = CustomTextField(title: "Email *", placeholder: "Masukkan email")
    private let passwordTF = CustomTextField(title: "Password *", placeholder: "Masukkan password", isSecure: true)
    private let nameTF = CustomTextField(title: "Full Name *", placeholder: "Masukkan nama lengkap")
    private let phoneTF = CustomTextField(title: "Phone", placeholder: "Optional")
    
    private let signupButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Register", for: .normal)
        btn.backgroundColor = .lightGray
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.isEnabled = false
        return btn
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        let text = "Sudah punya akun? Login"
        let attr = NSMutableAttributedString(string: text)
        attr.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: (text as NSString).range(of: "Login"))
        label.attributedText = attr
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
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
        containerView.addSubview(emailTF)
        containerView.addSubview(passwordTF)
        containerView.addSubview(nameTF)
        containerView.addSubview(phoneTF)
        containerView.addSubview(signupButton)
        
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
        
        emailTF.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.left.right.equalToSuperview()
        }
        
        passwordTF.snp.makeConstraints { make in
            make.top.equalTo(emailTF.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        
        nameTF.snp.makeConstraints { make in
            make.top.equalTo(passwordTF.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        
        phoneTF.snp.makeConstraints { make in
            make.top.equalTo(nameTF.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(phoneTF.snp.bottom).offset(32)
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
        
        let input = SignupViewModel.Input(
            email: emailTF.textField.rx.text.orEmpty.asObservable(),
            password: passwordTF.textField.rx.text.orEmpty.asObservable(),
            fullName: nameTF.textField.rx.text.orEmpty.asObservable(),
            phone: phoneTF.textField.rx.text.orEmpty.asObservable(),
            signupTap: signupButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isButtonEnabled
            .bind(to: signupButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.isButtonEnabled
            .subscribe(onNext: { [weak self] isValid in
                self?.signupButton.backgroundColor = isValid ?  UIColor(red: 0.18, green: 0.24, blue: 0.45, alpha: 1.0) : .lightGray
            })
            .disposed(by: disposeBag)
        
        output.success
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self?.navigationController?.popViewController(animated: true)
                })
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
        
        let tap = UITapGestureRecognizer()
        footerLabel.isUserInteractionEnabled = true
        footerLabel.addGestureRecognizer(tap)
        
        tap.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
