//
//  SignupViewModel.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//

import Foundation
import RxSwift
import RxCocoa

final class SignupViewModel {
    
    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let fullName: Observable<String>
        let phone: Observable<String>
        let signupTap: Observable<Void>
    }
    
    struct Output {
        let isButtonEnabled: Observable<Bool>
        let loading: Observable<Bool>
        let success: Observable<String>
        let error: Observable<String>
    }
    
    private let service: APIServiceProtocol
    private let disposeBag = DisposeBag()
    
    init(service: APIServiceProtocol = APIService.shared) {
        self.service = service
    }
    
    func transform(input: Input) -> Output {
        
        let loading = PublishRelay<Bool>()
        let errorRelay = PublishRelay<String>()
        let successRelay = PublishRelay<String>()
        
        let isValid = Observable.combineLatest(
            input.email,
            input.password,
            input.fullName
        )
        .map { !$0.isEmpty && $1.count >= 6 && !$2.isEmpty }
        .share(replay: 1)
        
        input.signupTap
            .withLatestFrom(Observable.combineLatest(
                input.email,
                input.password,
                input.fullName,
                input.phone
            ))
            .flatMapLatest { [weak self] email, password, fullName, phone -> Observable<Event<RegisterResponse>> in
                
                guard let self = self else { return .empty() }
                
                loading.accept(true)
                
                let request = RegisterRequest(
                    email: email,
                    password: password,
                    fullName: fullName,
                    phone: phone.isEmpty ? nil : phone
                )
                
                return self.service.register(request: request)
                    .asObservable()
                    .materialize()
            }
            .subscribe(onNext: { event in
                loading.accept(false)
                
                switch event {
                case .next(let response):
                    successRelay.accept(response.message)
                case .error(let error):
                    errorRelay.accept("error data")
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        return Output(
            isButtonEnabled: isValid,
            loading: loading.asObservable(),
            success: successRelay.asObservable(),
            error: errorRelay.asObservable()
        )
    }
}
