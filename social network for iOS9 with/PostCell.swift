//
//  PostCell.swift
//  social network for iOS9 with
//
//  Created by Lê Thanh Tùng on 3/18/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgShowCase: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var imgLikes: UIImageView!
    
    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        
        imgLikes.addGestureRecognizer(tap)
        imgLikes.userInteractionEnabled = true
    }

    override func drawRect(rect: CGRect) {
        imgProfile.layer.cornerRadius = imgProfile.frame.size.width / 2
        imgProfile.clipsToBounds = true
        
        imgShowCase.clipsToBounds = true
    }
    
    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)

        self.descriptionText.text = post.description
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            self.imgShowCase.hidden = false
            
            if img != nil {
                self.imgShowCase.image = img
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) -> Void in
                    
                    if error == nil {
                        
                        let img = UIImage(data: data!)!
                        self.imgShowCase.image = img
                        
                        //save cache
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                    
                })
            }
        } else {
            self.imgShowCase.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.imgLikes.image = UIImage(named: "heart-empty")
            } else {
                self.imgLikes.image = UIImage(named: "heart-full")
            }
            
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {
                self.imgLikes.image = UIImage(named: "heart-full")
                self.post.adjustLike(true)
                self.likeRef.setValue(true)
            } else {
                self.imgLikes.image = UIImage(named: "heart-empty")
                self.post.adjustLike(false)
                self.likeRef.removeValue()
            }
            
        })
    }
    
    
}
