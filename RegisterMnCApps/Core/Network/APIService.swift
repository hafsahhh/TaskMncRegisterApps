//
//  APIService.swift
//  RegisterMnCApps
//
//  Created by Siti Hafsah on 31/03/26.
//
import Foundation
import RxSwift

protocol APIServiceProtocol {
    func login(email: String, password: String) -> Single<LoginResponse>
    func register(request: RegisterRequest) -> Single<RegisterResponse>
    func getProfile(token: String) -> Observable<ProfileResponse>
}

final class APIService: APIServiceProtocol {
    
    static let shared = APIService()
    private init() {}
    
    private let baseURL = "https://api-test.partaiperindo.com/api/v1"
    
    func login(email: String, password: String) -> Single<LoginResponse> {
        
        return Single.create { single in
            
            guard let url = URL(string: self.baseURL + "/login") else {
                single(.failure(NSError(domain: "Invalid URL", code: -1)))
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "email": email,
                "password": password
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let data = data else {
                    single(.failure(NSError(domain: "No Data", code: -1)))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                    single(.success(response))
                } catch {
                    single(.failure(error))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    func register(request: RegisterRequest) -> Single<RegisterResponse> {
        
        return Single.create { single in
            
            guard let url = URL(string: self.baseURL + "/register") else {
                single(.failure(NSError(domain: "Invalid URL", code: -1)))
                return Disposables.create()
            }
            
            var requestURL = URLRequest(url: url)
            requestURL.httpMethod = "POST"
            requestURL.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                requestURL.httpBody = try JSONEncoder().encode(request)
            } catch {
                single(.failure(error))
                return Disposables.create()
            }
            
            let task = URLSession.shared.dataTask(with: requestURL) { data, _, error in
                
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let data = data else {
                    single(.failure(NSError(domain: "No Data", code: -1)))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(RegisterResponse.self, from: data)
                    single(.success(response))
                } catch {
                    single(.failure(error))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func getProfile(token: String) -> Observable<ProfileResponse> {
        return Observable.create { observer in
            
            guard let url = URL(string: "\(self.baseURL)/profile") else {
                observer.onError(NSError(domain: "Invalid URL", code: -1))
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let data = data else {
                    observer.onError(NSError(domain: "No Data", code: -1))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(ProfileResponse.self, from: data)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
