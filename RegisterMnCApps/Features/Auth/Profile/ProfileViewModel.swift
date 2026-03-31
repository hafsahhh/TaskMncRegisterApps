//
//  ProfileViewModel.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel {
    
    // Output
    let profile: BehaviorRelay<ProfileResponse>
    
    init(profile: ProfileResponse) {
        self.profile = BehaviorRelay(value: profile)
    }
}
