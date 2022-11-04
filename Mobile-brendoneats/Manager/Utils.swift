//
//  Utils.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/12/21.
//

import Foundation

class Utils {
    
    
    static func loadImage(_ imageView: UIImageView,_ urlString: String) {
        let imgURL: URL = URL(string: urlString)!
        URLSession.shared.dataTask(with: imgURL) {
            (data, response, error) in
            guard let data = data, error == nil else { return }
        
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
