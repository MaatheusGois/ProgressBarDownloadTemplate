//
//  GenericDownloadTask.swift
//  ProgressBarDownload
//
//  Created by Matheus Silva on 20/04/20.
//  Copyright © 2020 Matheus Gois. All rights reserved.
//

import Foundation

class GenericTask {

   var completionHandler: ResultType<Data>.Completion?
   var progressHandler: ((Float) -> Void)?

   private(set) var task: URLSessionDataTask
   var expectedContentLength: Int64 = 0
   var buffer = Data()

   init(task: URLSessionDataTask) {
      self.task = task
   }

   deinit {
      print("Deinit: \(task.originalRequest?.url?.absoluteString ?? "")")
   }

}

extension GenericTask: Task {
    
   func resume() { task.resume() }
    
   func suspend() { task.suspend() }
    
   func cancel() { task.cancel() }
}
