//
//  UIImageExtension.swift
//  LetSwift
//
//  Created by Kinga Wilczek, Marcin Chojnacki on 27.04.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

extension UIImage {
    func resized(with percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func tinted(with color: UIColor) -> UIImage {
        guard let filter = CIFilter(name: "CIColorMonochrome") else { return self }
        
        filter.setValue(CIColor(color: color), forKey: kCIInputColorKey)
        
        return filtered(by: filter) ?? self
    }
    
    private func filtered(by filter: CIFilter) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let ciOutput = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return nil }
        
        let output = UIImage(ciImage: ciOutput, scale: scale, orientation: imageOrientation)
        UIGraphicsBeginImageContextWithOptions(output.size, false, scale)
        output.draw(in: CGRect(origin: .zero, size: output.size))
        let finalOutput = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalOutput
    }
}