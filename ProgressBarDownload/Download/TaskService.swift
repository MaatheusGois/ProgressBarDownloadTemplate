//
//  DownloadService.swift
//  ProgressBarDownload
//
//  Created by Matheus Silva on 20/04/20.
//  Copyright © 2020 Matheus Gois. All rights reserved.
//

import UIKit

final class TaskService: NSObject {
    
    private var session: URLSession!
    private var downloadTasks = [GenericTask]()
    
    public static let shared = TaskService()
    
    private override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration,
                             delegate: self, delegateQueue: nil)
    }
    
    func download(request: URLRequest) -> Task {
        let task = session.dataTask(with: request)
        let downloadTask = GenericTask(task: task)
        downloadTasks.append(downloadTask)
        return downloadTask
    }
    func upload(request: URLRequest, data: Data) -> Task {
        let task = session.uploadTask(with: request, from: data)
        let downloadTask = GenericTask(task: task)
        downloadTasks.append(downloadTask)
        return downloadTask
    }
}


extension TaskService: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let task = downloadTasks.first(where: { $0.task == dataTask }) else {
            completionHandler(.cancel)
            return
        }
        task.expectedContentLength = response.expectedContentLength
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let index = downloadTasks.firstIndex(where: { $0.task == task }) else {
            return
        }
        let task = downloadTasks.remove(at: index)
        DispatchQueue.main.async {
            if let e = error {
                task.completionHandler?(.failure(e))
            } else {
                task.completionHandler?(.success(task.buffer))
            }
        }
    }
    
    // MARK:- UPLOAD
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let task = downloadTasks.first(where: { $0.task == task }) else {
            return
        }
        let percentageDownloaded = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            task.progressHandler?(percentageDownloaded)
        }
    }
    
    // MARK:- DOWNLOAD
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let task = downloadTasks.first(where: { $0.task == dataTask }) else {
            return
        }
        task.buffer.append(data)
        let percentageDownloaded = Float(task.buffer.count) / Float(task.expectedContentLength)
        DispatchQueue.main.async {
            task.progressHandler?(percentageDownloaded)
        }
    }
}
