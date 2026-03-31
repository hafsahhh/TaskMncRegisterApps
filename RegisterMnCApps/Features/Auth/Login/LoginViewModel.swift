//
//  LoginViewModel.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel {
    
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let loginTap: Observable<Void>
    }
    
    struct Output {
        let isButtonEnabled: Observable<Bool>
        let loading: Observable<Bool>
        let loginSuccess: Observable<Void>
        let error: Observable<String>
    }
    
    private let service: APIServiceProtocol
    private let disposeBag = DisposeBag()
    
    init(service: APIServiceProtocol = APIService.shared) {
        self.service = service
    }
    
    func transform(input: Input) -> Output {
        
        let activity = PublishRelay<Bool>()
        let errorRelay = PublishRelay<String>()
        
        let isValid = Observable.combineLatest(input.email, input.password)
            .map { !$0.isEmpty && $1.count >= 6 }
            .share(replay: 1)
        
        let loginResult = input.loginTap
            .withLatestFrom(Observable.combineLatest(input.email, input.password))
            .flatMapLatest { [weak self] email, password -> Observable<Event<LoginResponse>> in
                
                guard let self = self else { return .empty() }
                
                activity.accept(true)
                
                return self.service.login(email: email, password: password)
                    .asObservable()
                    .materialize()
            }
            .share()
        
        let success = loginResult.compactMap { $0.element }
        let failure = loginResult.compactMap { $0.error }
        
        success
            .subscribe(onNext: { [weak self] response in
                KeychainManager.shared.saveToken(response.token)
                activity.accept(false)
            })
            .disposed(by: disposeBag)
        

        failure
            .subscribe(onNext: { error in
                errorRelay.accept(error.localizedDescription)
                activity.accept(false)
            })
            .disposed(by: disposeBag)
        
        return Output(
            isButtonEnabled: isValid,
            loading: activity.asObservable(),
            loginSuccess: success.map { _ in () },
            error: errorRelay.asObservable()
        )
    }
}
