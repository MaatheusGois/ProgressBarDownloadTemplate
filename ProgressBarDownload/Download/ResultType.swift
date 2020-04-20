//
//  public enum ResultType<T> {     public typealias Completion = (ResultType<T>) -> Void     case success(T)    case failure(Swift.Error)  }.swift
//  ProgressBarDownload
//
//  Created by Matheus Silva on 20/04/20.
//  Copyright © 2020 Matheus Gois. All rights reserved.
//

import Foundation
public enum ResultType<T> {

   public typealias Completion = (ResultType<T>) -> Void

   case success(T)
   case failure(Swift.Error)

}
