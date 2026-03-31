//
//  HomeViewModel.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel {
    
    private let service: APIServiceProtocol
    private let disposeBag = DisposeBag()
    
    // Output
    let profile = PublishRelay<ProfileResponse>()
    let error = PublishRelay<String>()
    let loading = PublishRelay<Bool>()
    
    init(service: APIServiceProtocol = APIService.shared) {
        self.service = service
    }
    func fetchProfile(token: String) {
        loading.accept(true)
        
        service.getProfile(token: token)
            .subscribe(
                onNext: { [weak self] response in
                    self?.loading.accept(false)
                    self?.profile.accept(response)
                },
                onError: { [weak self] err in
                    self?.loading.accept(false)
                    self?.error.accept(err.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
}
