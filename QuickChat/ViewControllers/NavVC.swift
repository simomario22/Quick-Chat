//
//  NavVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/27/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class NavVC: UINavigationController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    //MARK: Properties
    @IBOutlet var contactsView: UIView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var previewView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profilePicView: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    var topAnchorContraint: NSLayoutConstraint!
    let darkView = UIView.init()
    var items = [User]()
    
    //MARK: Methods
    func customization() {
        //DarkView customization
        self.view.addSubview(self.darkView)
        self.darkView.backgroundColor = UIColor.black
        self.darkView.alpha = 0
        self.darkView.translatesAutoresizingMaskIntoConstraints = false
        self.darkView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.darkView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.darkView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.darkView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.darkView.isHidden = true
    //ContainerView customization
        let extraViewsContainer = UIView.init()
        extraViewsContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(extraViewsContainer)
        self.topAnchorContraint = NSLayoutConstraint.init(item: extraViewsContainer, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.topAnchorContraint.isActive = true
        extraViewsContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        extraViewsContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        extraViewsContainer.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        extraViewsContainer.backgroundColor = UIColor.clear
    //ContactsView customization
        extraViewsContainer.addSubview(self.contactsView)
        self.contactsView.translatesAutoresizingMaskIntoConstraints = false
        self.contactsView.topAnchor.constraint(equalTo: extraViewsContainer.topAnchor).isActive = true
        self.contactsView.leadingAnchor.constraint(equalTo: extraViewsContainer.leadingAnchor).isActive = true
        self.contactsView.trailingAnchor.constraint(equalTo: extraViewsContainer.trailingAnchor).isActive = true
        self.contactsView.bottomAnchor.constraint(equalTo: extraViewsContainer.bottomAnchor).isActive = true
        self.contactsView.isHidden = true
        self.collectionView?.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        self.contactsView.backgroundColor = UIColor.clear
    //ProfileView Customization
        extraViewsContainer.addSubview(self.profileView)
        self.profileView.translatesAutoresizingMaskIntoConstraints = false
        self.profileView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width * 0.9)).isActive = true
        let profileViewAspectRatio = NSLayoutConstraint.init(item: self.profileView, attribute: .width, relatedBy: .equal, toItem: self.profileView, attribute: .height, multiplier: 0.8125, constant: 0)
        profileViewAspectRatio.isActive = true
        self.profileView.centerXAnchor.constraint(equalTo: extraViewsContainer.centerXAnchor).isActive = true
        self.profileView.centerYAnchor.constraint(equalTo: extraViewsContainer.centerYAnchor).isActive = true
        self.profileView.layer.cornerRadius = 5
        self.profileView.clipsToBounds = true
        self.profileView.isHidden = true
        self.profilePicView.layer.borderColor = GlobalVariables.purple.cgColor
        self.profilePicView.layer.borderWidth = 3
        self.view.layoutIfNeeded()
    //PreviewView Customization
        extraViewsContainer.addSubview(self.previewView)
        self.previewView.isHidden = true
        self.previewView.translatesAutoresizingMaskIntoConstraints = false
        self.previewView.leadingAnchor.constraint(equalTo: extraViewsContainer.leadingAnchor).isActive = true
        self.previewView.topAnchor.constraint(equalTo: extraViewsContainer.topAnchor).isActive = true
        self.previewView.trailingAnchor.constraint(equalTo: extraViewsContainer.trailingAnchor).isActive = true
        self.previewView.bottomAnchor.constraint(equalTo: extraViewsContainer.bottomAnchor).isActive = true
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
    //NotificationCenter for showing extra views
        NotificationCenter.default.addObserver(self, selector: #selector(self.showExtraViews(notification:)), name: NSNotification.Name(rawValue: "showExtraView"), object: nil)
    }
    
    func dismissExtraViews() {
        UIApplication.shared.isStatusBarHidden = false
        self.topAnchorContraint.constant = 1000
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.darkView.alpha = 0
            self.view.transform = CGAffineTransform.identity
        }, completion:  { (true) in
            self.darkView.isHidden = true
            self.profileView.isHidden = true
            self.contactsView.isHidden = true
            self.previewView.isHidden = true
            let vc = self.viewControllers.last
            vc?.inputAccessoryView?.isHidden = false
        })
    }
    
    func showExtraViews(notification: NSNotification)  {
        let transform = CGAffineTransform.init(scaleX: 0.94, y: 0.94)
        self.topAnchorContraint.constant = 0
        self.darkView.isHidden = false
        if let type = notification.userInfo?["viewType"] as? ShowExtraView {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.darkView.alpha = 0.8
                if (type == .contacts || type == .profile) {
                    self.view.transform = transform
                }
            })
            switch type {
            case .contacts:
                self.contactsView.isHidden = false
                if self.items.count == 0 {
                    self.fetchUsers()
                }
            case .profile:
                self.profileView.isHidden = false
                self.fetchUserInfo()
            case .preview:
                self.previewView.isHidden = false
                UIApplication.shared.isStatusBarHidden = true
                self.previewImageView.image = notification.userInfo?["pic"] as? UIImage
            }
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = self.previewImageView.frame.size.height / scale
        zoomRect.size.width  = self.previewImageView.frame.size.width  / scale
        let newCenter = self.previewImageView.convert(center, from: self.scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func fetchUsers()  {
        GlobalVariables.users.observe(.childAdded, with: { (snapshot) in
            let output = snapshot.value as! [String: String]
            let name = output["name"]!
            let email = output["email"]!
            let profilePicLink = output["profilePicLink"]!
            let link = URL.init(string: profilePicLink)
            let data = try! Data.init(contentsOf: link!)
            let profilePic = UIImage.init(data: data)!
            let user = User.init(name: name, email: email, id: snapshot.key, profilePicLink: link!, profilePic: profilePic)
            self.items.append(user)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    func fetchUserInfo() {
        if let id  = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(id).observe(.value, with: { (snapshot) in
                let value = snapshot.value as! [String : String]
                self.nameLabel.text = value["email"]
                self.emailLabel.text = value["name"]
                let profilePicURL = URL.init(string: value["profilePicLink"]!)
                let imageData = try! Data.init(contentsOf: profilePicURL!)
                let profilePic = UIImage.init(data: imageData)
                self.profilePicView.image = profilePic
            })
        }
    }
    
    @IBAction func doubleTapGesture(_ sender: UITapGestureRecognizer) {
        if self.scrollView.zoomScale == 1 {
            self.scrollView.zoom(to: zoomRectForScale(scale: self.scrollView.maximumZoomScale, center: sender.location(in: sender.view)), animated: true)
        } else {
            self.scrollView.setZoomScale(1, animated: true)
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismissExtraViews()
    }
  
    @IBAction func logOutUser(_ sender: Any) {
        if let _ = FIRAuth.auth()?.currentUser?.uid {
            do {
                try FIRAuth.auth()?.signOut()
                UserDefaults.standard.removeObject(forKey: "userInformation")
                self.dismiss(animated: true, completion: nil)
            } catch _ {
                print("something went wrong")
            }
        }
    }
    
    //MARK: Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.items.count == 0 {
            return 1
        } else {
            return self.items.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.items.count == 0 {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "Empty Cell", for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ContactsCVCell
            cell.profilePic.image = self.items[indexPath.row].profilePic
            cell.nameLabel.text = self.items[indexPath.row].name
            cell.profilePic.layer.borderWidth = 2
            cell.profilePic.layer.borderColor = GlobalVariables.purple.cgColor
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.items.count > 0 {
            self.dismissExtraViews()
            let userInfo = ["username": String(indexPath.row)]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showUserMessages"), object: nil, userInfo: userInfo)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.items.count == 0 {
            return self.collectionView.bounds.size
        } else {
            if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                let width = (0.3 * UIScreen.main.bounds.height)
                let height = width + 30
                return CGSize.init(width: width, height: height)
            } else {
                let width = (0.3 * UIScreen.main.bounds.width)
                let height = width + 30
                return CGSize.init(width: width, height: height)
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.previewImageView
    }

    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.transform = CGAffineTransform.identity
    }    
}

class ContactsCVCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
