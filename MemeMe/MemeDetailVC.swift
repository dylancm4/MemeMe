//
//  MemeDetailVC.swift
//  MemeMe
//
//  Created by Dylan Miller on 8/13/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class MemeDetailVC: UIViewController
{
    @IBOutlet weak var memeImageView: UIImageView!

    var memeIndex: Int?
    var tabBarWasHidden = false

    var appDelegate : AppDelegate
    {
        return (UIApplication.sharedApplication().delegate as! AppDelegate)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        // Hide tab bar.
        if let tabBarController = tabBarController
        {
            tabBarWasHidden = tabBarController.tabBar.hidden
            tabBarController.tabBar.hidden = true
        }

        // Set the image.
        if let memeIndex = memeIndex
        {
            memeImageView.image = appDelegate.memes[memeIndex].memedImage
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Un-hide the tab bar.
        if let tabBarController = tabBarController
        {
            tabBarController.tabBar.hidden = tabBarWasHidden
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let navigationController =
            segue.destinationViewController as? UINavigationController
        {
            if let memeEditorVC = navigationController.topViewController as? MemeEditorVC,
                memeIndex = memeIndex
            {
                memeEditorVC.editMemeIndex = memeIndex
            }
        }
    }
}
