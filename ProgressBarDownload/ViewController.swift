//
//  ViewController.swift
//  ProgressBarDownload
//
//  Created by Matheus Silva on 20/04/20.
//  Copyright © 2020 Matheus Gois. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var loadImageButton: UIButton!
    @IBOutlet fileprivate weak var loadProgressIndicator: UIProgressView!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    
    @IBOutlet fileprivate weak var uploadImageButton: UIButton!
    @IBOutlet fileprivate weak var uploadProgressIndicator: UIProgressView!
    
    fileprivate var downloadTask:  Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageButton.addTarget(self, action:  #selector(startDownload(_:)),
                                  for: .touchUpInside)
        uploadImageButton.addTarget(self, action: #selector(startUpload),
                                    for: .touchUpInside)
    }
}

extension ViewController {
    @objc fileprivate func startDownload(_ button: UIButton) {
        let url = URL(string: "https://s1.1zoom.me/big3/905/376149-alexfas01.jpg")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        
        downloadTask = TaskService.shared.download(request: request)
        downloadTask?.completionHandler = { [weak self] in
            switch $0 {
            case .failure(let error):
                print(error)
            case .success(let data):
                print("Number of bytes: \(data.count)")
                self?.imageView.image = UIImage(data: data)
            }
            self?.downloadTask = nil
            self?.loadImageButton.isEnabled = true
        }
        downloadTask?.progressHandler = { [weak self] in
            print("Task1: \($0)")
            self?.loadProgressIndicator.progress = $0
        }
        
        loadImageButton.isEnabled = false
        imageView.image = nil
        loadProgressIndicator.progress = 0
        downloadTask?.resume()
    }
    
    @objc fileprivate func startUpload() {
        guard let image = imageView.image else { return }
        uploadImage(paramName: "fileUploader", fileName: "image.png", image: image)
    }
    
    func uploadImage(paramName: String, fileName: String, image: UIImage) {
        let url = URL(string: "http://localhost:3000/upload")

        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        
        downloadTask = TaskService.shared.upload(request: urlRequest, data: data)
        downloadTask?.completionHandler = { [weak self] in
            switch $0 {
            case .failure(let error):
                print(error)
            case .success(let data):
                print("Number of bytes: \(data.count)")
            }
            self?.downloadTask = nil
            self?.uploadImageButton.isEnabled = true
        }
        downloadTask?.progressHandler = { [weak self] in
            print("Task1: \($0)")
            self?.uploadProgressIndicator.progress = $0
        }
        
        uploadImageButton.isEnabled = false
        uploadProgressIndicator.progress = 0
        downloadTask?.resume()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
}
