//
//  MemeEditorVC.swift
//  MemeMe
//
//  Created by Dylan Miller on 6/21/16.
//  Copyright © 2016 Dylan Miller. All rights reserved.
//

import UIKit
import AVFoundation

class MemeEditorVC:
    UIViewController, UIImagePickerControllerDelegate,
    UITextFieldDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var shareMemeButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextFieldLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextFieldWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldWidthConstraint: NSLayoutConstraint!
    
    var editMemeIndex: Int?
    var keyboardShowing = false
    var lastImagePickerViewFrame: CGRect?
    var lastImageSize: CGSize?

    var appDelegate : AppDelegate
    {
        return (UIApplication.sharedApplication().delegate as! AppDelegate)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureTextField(topTextField)
        configureTextField(bottomTextField)

        lastImagePickerViewFrame = nil
        lastImageSize = nil
        
        if let editMemeIndex = editMemeIndex // editing existing meme
        {
            let meme = appDelegate.memes[editMemeIndex]
            imagePickerView.image = meme.originalImage
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
        }
        
        // Adjust the constraints when the view loads.
        print("adjustConstraints: viewDidLoad")
        adjustConstraints(0)
    }
    
    func configureTextField(textField: UITextField)
    {
        // Set the font of the text field. Text should approximate the "Impact"
        // font, all caps, white with a black outline.
        let memeTextAttributes =
        [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0,
        ]
        textField.defaultTextAttributes = memeTextAttributes
        
        // Center align the text field.
        textField.textAlignment = .Center
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        // Subscribe to keyboard and orientation change notifications to adjust
        // the constraints when necessary.
        subscribeToNotifications()
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Unsubscribe from notifications.
        unsubscribeFromNotifications()
    }
    
    // Called to notify the view controller that its view has just laid out its
    // subviews.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Adjust the constraints when the interface orientation changes.
        // Attempted to use deviceOrientationDidChange notification for this
        // purpose, but imagePickerView.frame was not always set correctly
        // when notification function was called.
        print("adjustConstraints: viewDidLayoutSubviews")
        adjustConstraints(0)
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem)
    {
        // Generate memed image.
        if let memedImage = generateMemedImage()
        {
            // Create and present a UIActivityViewController, passing the
            // memedImage as an activity item, and save the meme if successful.
            let controller = UIActivityViewController(
                activityItems: [memedImage], applicationActivities: nil)
            controller.completionWithItemsHandler =
            {
                (activityType: String?, completed: Bool,
                 returnedItems: [AnyObject]?, activityError: NSError?) -> Void in
                    if completed
                    {
                        self.saveMeme(memedImage)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
            }
            presentViewController(controller, animated: true, completion: nil)
        }
   }
    
    @IBAction func cancelMeme(sender: UIBarButtonItem)
    {
        dismissViewControllerAnimated(true, completion: nil)

        /* MemeMe 1.0 code: Keep, in case we want to add a reset button.
        // Restore the default launch state, with no image a default text.
        imagePickerView.image = nil
        topTextField.text = topTextField.placeholder
        bottomTextField.text = bottomTextField.placeholder
        
        // Adjust the constraints when no image is selected.
        print("adjustConstraints: cancelMeme")
        adjustConstraints(0)(*/
    }
    
    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem)
    {
        pickImageFromSource(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem)
    {
        pickImageFromSource(UIImagePickerControllerSourceType.Camera)
    }
    
    func pickImageFromSource(source: UIImagePickerControllerSourceType)
    {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            imagePickerView.image = image
            
            // Adjust the constraints when an image is selected.
            print("adjustConstraints: imagePickerController")
            adjustConstraints(0)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subscribeToNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(MemeEditorVC.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(MemeEditorVC.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(
            self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(
            self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification)
    {
        if !keyboardShowing // keyboardShowing may already be true
        {
            keyboardShowing = true

            // Adjust the constraints when the keyboard will show.
            print("adjustConstraints: keyboardWillShow")
            let keyboardHeight = getKeyboardHeight(notification)
            adjustConstraints(-(keyboardHeight - toolbar.frame.height))
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if keyboardShowing // keyboardShowing should always be true
        {
            keyboardShowing = false
            
            // Adjust the constraints when the keyboard will hide.
            print("adjustConstraints: keyboardWillHide")
            let keyboardHeight = getKeyboardHeight(notification)
            adjustConstraints(keyboardHeight - toolbar.frame.height)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat
    {
        if let userInfo = notification.userInfo
        {
            if let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue // of CGRect
            {
                return keyboardSize.CGRectValue().height
            }
        }
        return 0
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        // When a user taps inside a text field, the default text should clear.
        // Instructions for assignment indicated that default text should be used,
        // perhaps because place holder text is hard to see against an image, but
        // we use place holder text here so that we can easily check if the text
        // is default text.
        if textField.text == textField.placeholder
        {
            textField.text = ""
        }
    }

    func textFieldDidEndEditing(textField: UITextField)
    {
        // If a text field is blank, restore the default text.
        if textField.text == ""
        {
            textField.text = textField.placeholder
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        // When a user presses return, the keyboard should be dismissed.
        textField.resignFirstResponder()
        return true
    }
    
    func generateMemedImage() -> UIImage?
    {
        let memedImage: UIImage?
        if let imagePickerViewImage = imagePickerView.image
        {
            // Calculate the size of the image with the aspect fit mode.
            var imageSizeAspectFit = AVMakeRectWithAspectRatioInsideRect(
                imagePickerViewImage.size, imagePickerView.frame)
            
            // Our calculated imageSizeAspectFit size may be slightly different
            // from the scaled image within imagePickerViewImage, so we subtract
            // 1 from the width and height so that our clipping does not clip
            // outside of the image bounds. This is slightly hacky, but it's the
            // best we can do when using the AVMakeRectWithAspectRatioInsideRect()
            // technique.
            imageSizeAspectFit.size.width -= 1
            imageSizeAspectFit.size.height -= 1
     
            // Render view to a memed image, clipping to the size of the
            // imagePickerView image.
            UIGraphicsBeginImageContext(imageSizeAspectFit.size)
            view.drawViewHierarchyInRect(
                CGRectMake(
                    -imageSizeAspectFit.origin.x,
                    -imageSizeAspectFit.origin.y,
                    view.bounds.size.width,
                    view.bounds.size.height),
                afterScreenUpdates: true)
            memedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        else
        {
            memedImage = nil
        }
     
        return memedImage
    }
 
    func saveMeme(memedImage: UIImage)
    {
        if let topText = topTextField.text,
            bottomText = bottomTextField.text,
            originalImage = imagePickerView.image
        {
            if let editMemeIndex = editMemeIndex // editing existing meme
            {
                appDelegate.memes[editMemeIndex].setProperties(
                    topText: topText,
                    bottomText: bottomText,
                    originalImage: originalImage,
                    memedImage: memedImage)
            }
            else
            {
                // Create a Meme object.
                let meme = Meme(
                    topText: topText,
                    bottomText: bottomText,
                    originalImage: originalImage,
                    memedImage: memedImage)
            
                // Add the meme to the appDelegate memes[] array.
                appDelegate.memes.append(meme)
            }
        }
    }
    
    // Adjust the image and text field constraints based on the adjustment to
    // the height of the image picker view, positioning and scaling to maintain
    // a WYSIWYG view.
    func adjustConstraints(imagePickerViewHeightAdjustment: CGFloat)
    {
        // Disable the share meme button when there is no image.
        shareMemeButton.enabled = imagePickerView.image != nil
        
        // Since changing imagePickerViewBottomConstraint.constant does not change
        // imagePickerView.frame immediately, we create imagePickerViewFrameAdjusted
        // to represent what imagePickerView.frame will be changed to.
        let imagePickerViewFrameAdjusted = CGRect(
            x: imagePickerView.frame.origin.x,
            y: imagePickerView.frame.origin.y,
            width: imagePickerView.frame.width,
            height: imagePickerView.frame.height + imagePickerViewHeightAdjustment)
        
        // If there is no image, use the size of the adjusted image picker view
        // when adjusting constraints.
        let imageSize = imagePickerView.image != nil ?
            imagePickerView.image!.size :
            CGSize(
                width: imagePickerViewFrameAdjusted.width,
                height: imagePickerViewFrameAdjusted.height)
        
        // Avoid redundantly setting constraints.
        if let lastImagePickerViewFrame = lastImagePickerViewFrame,
            lastImageSize = lastImageSize
        {
            if lastImagePickerViewFrame == imagePickerView.frame &&
                lastImageSize == imageSize &&
                imagePickerViewHeightAdjustment == 0
            {
                print("No adjustments necessary\n")
                return
            }
                
        }
        lastImagePickerViewFrame = imagePickerView.frame
        lastImageSize = imageSize
            
        // Update the image view constraints.
        imagePickerViewBottomConstraint.constant += imagePickerViewHeightAdjustment

        // Calculate the size of the image with the aspect fit mode.
        let imageSizeAspectFit = AVMakeRectWithAspectRatioInsideRect(
            imageSize, imagePickerViewFrameAdjusted)
        
        // Update the text field constraints. Note that an "Unable to
        // simultaneously satisfy constraints" warning may occur when the
        // device is rotated but before this function has been called to
        // adjust the constraints based on the new rotation. This is harmless.
        let textFieldVerticalOffset: CGFloat = 20
        let leadingConstraint =
            imageSizeAspectFit.origin.x - imagePickerViewFrameAdjusted.origin.x
        let widthConstraint =
            -(imagePickerViewFrameAdjusted.width - imageSizeAspectFit.width)

        topTextFieldTopConstraint.constant =
            imageSizeAspectFit.origin.y - imagePickerViewFrameAdjusted.origin.y +
            textFieldVerticalOffset
        topTextFieldLeadingConstraint.constant = leadingConstraint
        topTextFieldWidthConstraint.constant = widthConstraint
        bottomTextFieldBottomConstraint.constant =
            imageSizeAspectFit.origin.y + imageSizeAspectFit.height -
            textFieldVerticalOffset - (imagePickerViewFrameAdjusted.origin.y +
                imagePickerViewFrameAdjusted.height)
        bottomTextFieldLeadingConstraint.constant = leadingConstraint
        bottomTextFieldWidthConstraint.constant = widthConstraint

        print("imagePickerView.frame = \(imagePickerView.frame)")
        print("imagePickerViewHeightAdjustment = \(imagePickerViewHeightAdjustment)")
        print("imagePickerViewFrameAdjusted = \(imagePickerViewFrameAdjusted)")
        print("imageSizeAspectFit = \(imageSizeAspectFit)")
        print("topTextFieldTopConstraint.constant = \(topTextFieldTopConstraint.constant)")
        print("topTextFieldLeadingConstraint.constant = \(topTextFieldLeadingConstraint.constant)")
        print("topTextFieldWidthConstraint.constant = \(topTextFieldWidthConstraint.constant)")
        print("bottomTextFieldBottomConstraint.constant = \(bottomTextFieldBottomConstraint.constant)")
        print("bottomTextFieldLeadingConstraint.constant = \(bottomTextFieldLeadingConstraint.constant)")
        print("bottomTextFieldWidthConstraint.constant = \(bottomTextFieldWidthConstraint.constant)\n")
    }
}

