//
//  Extenstions.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import Foundation
import UIKit
import SnapKit

class CustomTextField: UIView {
    
    let textField = UITextField()
    private let titleLabel = UILabel()
    private var eyeButton: UIButton?
    
    private var isSecureField: Bool = false
    
    init(title: String, placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        
        self.isSecureField = isSecure
        
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .darkGray
        
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.lightGray.cgColor
        
        if isSecure {
            setupPasswordToggle()
        }
        
        addSubview(titleLabel)
        addSubview(textField)
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
    }
    
    private func setupPasswordToggle() {
        textField.isSecureTextEntry = true
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        button.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        
        textField.rightView = button
        textField.rightViewMode = .always
        
        self.eyeButton = button
    }
    
    @objc private func togglePassword() {
        textField.isSecureTextEntry.toggle()
        
        let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
        eyeButton?.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
