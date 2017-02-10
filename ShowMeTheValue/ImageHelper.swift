//
//  ImageHelper.swift
//  ShowMeTheValue
//
//  Created by David Michaeloff on 1/18/17.
//  Copyright © 2017 David Michaeloff. All rights reserved.
//

// Image helper class with static functions so instantiation is not needed. (Xcode 8 - Swift 3)
//
// Example usage of asynchronous downloadImage():
//
// override func viewDidLoad() {
//    super.viewDidLoad()
//    if let checkedUrl = URL(string: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png") {
//        imageView.contentMode = .scaleAspectFit
//        downloadImage(url: checkedUrl)
//    }
//    // The image will continue downloading in the background and it will be loaded when it ends.
//}

import UIKit

class ImageHelper {
    
    // Synchronous
    static func synchronousGetImageFromFile(imageName:String, imageExtension:String) -> UIImage {
        if let filePath = Bundle.main.path(forResource: imageName, ofType: imageExtension), let image = UIImage(contentsOfFile: filePath) {
            return image
        }
        return UIImage()
    }
    
    // Asynchronous
    // Create a method to download the image (start the task)
    static func downloadImage(url: URL, imageView: UIImageView) {

        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print("Downloaded image:" + (response?.suggestedFilename ?? url.lastPathComponent))

            DispatchQueue.main.async() { () -> Void in
                imageView.image = UIImage(data: data)
            }
        }
    }
    
    // Creates a URL data task with a completion handler to get the image data from the url
    static private func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
}

// Example usage of extension:
// imageView.downloadedFrom(link: "http://www.apple.com/euro/ios/ios8/a/generic/images/og.png")

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
