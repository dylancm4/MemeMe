//
//  MemeTableVC.swift
//  MemeMe
//
//  Created by Dylan Miller on 8/11/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit

class MemeTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!

    var appDelegate : AppDelegate
    {
        return (UIApplication.sharedApplication().delegate as! AppDelegate)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.rowHeight = 80
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return appDelegate.memes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as! MemeTableViewCell
        let meme = appDelegate.memes[indexPath.row]
        
        // Set the image and labels.
        cell.memeImageView?.image = meme.memedImage
        cell.topTextLabel?.text = meme.topText
        cell.bottomTextLabel?.text = meme.bottomText
        
        return cell
    }
    
    /* KEEP: Code to segue to MemeDetailVC programatically.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        /*let memeDetailVC = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailVC") as! MemeDetailVC
        memeDetailVC.memeIndex = indexPath.row
        navigationController!.pushViewController(memeDetailVC, animated: true)*/
    }*/
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        // Swipe to delete
        if editingStyle == .Delete
        {
            appDelegate.memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let memeDetailVC = segue.destinationViewController as? MemeDetailVC,
            indexPath = tableView.indexPathForSelectedRow
        {            
            memeDetailVC.memeIndex = indexPath.row
        }
    }
}
