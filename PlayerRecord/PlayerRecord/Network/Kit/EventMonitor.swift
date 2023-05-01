//
//  EventMonitor.swift
//  PlayerRecord
//
//  Created by 박성준 on 2023/05/01.
//

import Foundation

public protocol EventMonitor {
    var queue: DispatchQueue { get }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive data: Data)
    
    func request(_ request: Request, didResumeTask task: URLSessionTask)
    func request(_ request: Request, didSuspendTask task: URLSessionTask)
    func requestIsRetrying(_ request: Request)
    func requestDidFinish(_ request: Request)
    func requestDidResume(_ request: Request)
    func requestDidSuspend(_ request: Request)
}
