//
//  DownloadTask.swift
//  ProgressBarDownload
//
//  Created by Matheus Silva on 20/04/20.
//  Copyright © 2020 Matheus Gois. All rights reserved.
//

import Foundation

protocol Task {

   var completionHandler: ResultType<Data>.Completion? { get set }
   var progressHandler: ((Float) -> Void)? { get set }

   func resume()
   func suspend()
   func cancel()
}
