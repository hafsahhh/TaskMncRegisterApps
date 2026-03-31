//
//  Auth.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import Foundation

struct LoginResponse: Codable {
    let token: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let fullName: String
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case fullName = "full_name"
        case phone
    }
}

struct RegisterResponse: Codable {
    let message: String
}

struct ProfileResponse: Decodable {
    let id: String
    let fullName: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
    }
}
