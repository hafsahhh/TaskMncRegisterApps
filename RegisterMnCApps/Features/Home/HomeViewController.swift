//
//  HomeViewController.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()
    private var currentProfile: ProfileResponse?
    
    // MARK: - UI Components
    private let headerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Register Offline"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.15, green: 0.20, blue: 0.38, alpha: 1.0)
        return label
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Yudi Wiranto", for: .normal)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.tintColor = .gray
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 15
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Draft", "Sudah Di-Upload"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .clear
        sc.selectedSegmentTintColor = .clear
        sc.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        sc.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.gray, .font: UIFont.systemFont(ofSize: 14)], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue, .font: UIFont.systemFont(ofSize: 14, weight: .bold)], for: .selected)
        return sc
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let emptyIllustration: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "image 1")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Belum ada data"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let emptySubLabel: UILabel = {
        let label = UILabel()
        label.text = "Klik \"Tambah Data\" untuk menambahkan data calon anggota"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("+ Tambah Data", for: .normal)
        btn.backgroundColor = UIColor(red: 0.15, green: 0.20, blue: 0.38, alpha: 1.0)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        return btn
    }()
    
    private let uploadButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Upload Semua", for: .normal)
        btn.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        btn.tintColor = .lightGray
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.cornerRadius = 8
        btn.isEnabled = false
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupRx()
        fetchProfile()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        [headerView, segmentedControl, underlineView, emptyIllustration,
         emptyTitleLabel, emptySubLabel, addButton, uploadButton].forEach { view.addSubview($0) }
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(profileButton)
    }
    
    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }
        
        profileButton.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        underlineView.snp.makeConstraints { make in
            make.bottom.equalTo(segmentedControl.snp.bottom)
            make.height.equalTo(2)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.left.equalToSuperview()
        }
        
        emptyIllustration.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(150)
        }
        
        emptyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyIllustration.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(40)
        }
        
        emptySubLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyTitleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(40)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(uploadButton.snp.top).offset(-12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
    }
    
    private func setupRx() {
        segmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                let screenWidth = UIScreen.main.bounds.width
                UIView.animate(withDuration: 0.3) {
                    self.underlineView.snp.updateConstraints { make in
                        make.left.equalTo(index == 0 ? 0 : screenWidth / 2)
                    }
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .bind {
                print("Navigasi ke form tambah data...")
            }
            .disposed(by: disposeBag)
        
        // BIND PROFILE
        viewModel.profile
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] profile in
                self?.currentProfile = profile
                self?.profileButton.setTitle(profile.fullName, for: .normal)
            })
            .disposed(by: disposeBag)
        
        profileButton.rx.tap
            .compactMap { [weak self] in
                self?.currentProfile
            }
            .bind { [weak self] profile in
                let profileVC = ProfileViewController(profile: profile)
                self?.navigationController?.pushViewController(profileVC, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchProfile() {
        guard let token = KeychainManager.shared.getToken() else {
            print("Token tidak ditemukan")
            return
        }
        
        viewModel.fetchProfile(token: token)
    }
}
