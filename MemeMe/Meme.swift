//
//  Meme.swift
//  MemeMe
//
//  Created by Dylan Miller on 8/13/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

struct Meme
{
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
    
    init(
        topText: String, bottomText: String, originalImage: UIImage,
        memedImage: UIImage)
    {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
    
    mutating func setProperties(
        topText topText: String, bottomText: String, originalImage: UIImage,
        memedImage: UIImage)
    {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
