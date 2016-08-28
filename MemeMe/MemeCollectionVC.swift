//
//  MemeCollectionVC.swift
//  MemeMe
//
//  Created by Dylan Miller on 8/11/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class MemeCollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
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
        
        collectionView.reloadData()
    }
    
    // Called to notify the view controller that its view has just laid out its
    // subviews.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let frameSize = collectionView.frame.size
        let isPortrait = frameSize.width < frameSize.height
        let cellsPerRow: CGFloat = isPortrait ? 3 : 5
        
        let space: CGFloat = 1
        let dimension = frameSize.width / cellsPerRow - 2 * space

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        flowLayout.invalidateLayout() // trigger layout update
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return appDelegate.memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = appDelegate.memes[indexPath.row]
        
        // Set the image.
        cell.memeImageView?.image = meme.memedImage
        
        return cell
    }

    /* KEEP: Code to segue to MemeDetailVC programatically.
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let memeDetailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailVC") as! MemeDetailVC
        memeDetailVC.memeIndes = indexPath.row
        navigationController!.pushViewController(memeDetailVC, animated: true)
    }*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let memeDetailVC = segue.destinationViewController as? MemeDetailVC,
            indexPaths = collectionView.indexPathsForSelectedItems()
        {
            memeDetailVC.memeIndex = indexPaths[0].row
        }
    }
}
