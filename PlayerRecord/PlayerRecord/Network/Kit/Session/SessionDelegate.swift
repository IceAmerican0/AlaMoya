//
//  SessionDelegate.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/05/02.
//

import Foundation

open class SessionDelegate: NSObject {
    weak var stateProvider: SessionStateProvider?
    var eventMonitor: EventMonitor?
    
    func request<R: Request>(for task: URLSessionTask, as type: R.Type) -> R? {
        guard let provider = stateProvider else {
            assertionFailure("StateProvider is nil.")
            return nil
        }
        
        return provider.request(for: task) as? R
    }
}

extension SessionDelegate: URLSessionDelegate {
    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        eventMonitor?.urlSession(session, didBecomeInvalidWithError: error)
        
        stateProvider?.cancelRequestsForSessionInvalidation(with: error)
    }
}

extension SessionDelegate: URLSessionTaskDelegate {
    typealias ChallengeEvaluation = (disposition: URLSession.AuthChallengeDisposition, credintial: URLCredential?, error: NetworkError?)
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        eventMonitor?.urlSession(session, task: task, didReceive: challenge)
        
        let evaluation: ChallengeEvaluation
        switch challenge.protectionSpace.authenticationMethod {
        case NSURLAuthenticationMethodHTTPBasic, NSURLAuthenticationMethodHTTPDigest, NSURLAuthenticationMethodNTLM, NSURLAuthenticationMethodNegotiate:
            evaluation = attemptCredentialAuthentication(for: challenge, belongingTo: task)
        default:
            evaluation = (.performDefaultHandling, nil, nil)
        }
        
        if let error = evaluation.error {
            stateProvider?.request(for: task)?.didFailTask(task, earlyWithError: error)
        }
        
        completionHandler(evaluation.disposition, evaluation.credintial)
    }
    
    func attemptCredentialAuthentication(for challenge: URLAuthenticationChallenge,
                                         belongingTo task: URLSessionTask) -> ChallengeEvaluation {
        guard challenge.previousFailureCount == 0 else {
            return (.rejectProtectionSpace, nil, nil)
        }
        
        guard let credential = stateProvider?.credential(for: task, in: challenge.protectionSpace) else {
            return (.performDefaultHandling, nil, nil)
        }
        
        return (.useCredential, credential, nil)
    }
    
}

// TODO:
protocol SessionStateProvider: AnyObject {
    func request(for task: URLSessionTask) -> Request?
    func didCompleteTask(_ task: URLSessionTask, completion: @escaping () -> Void)
    func credential(for task: URLSessionTask, in protectionSpace: URLProtectionSpace) -> URLCredential
    func cancelRequestsForSessionInvalidation(with error: Error?)
}
