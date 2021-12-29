//
//  FriendViewController.swift
//  Friends
//
//  Created by SANGMIN YEOM on 2021/12/27.
//

import UIKit

class FriendViewController: UIViewController {
    
    var thumbnailImage: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var nationalityLabel: UILabel!
    @IBOutlet var fullStarButton: UIBarButtonItem!
    @IBOutlet var emptyStarButton: UIBarButtonItem!
    
    var friend: Person! {
        didSet {
            self.navigationItem.title = friend.name.first.uppercased()
            self.correctBarButtonState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FriendViewController {
    private func correctBarButtonState() {
        self.navigationItem.rightBarButtonItems = nil
        
        let rightBarButtonItem: UIBarButtonItem
        
        if Person.bestFriends.contains(self.friend) {
            rightBarButtonItem = self.fullStarButton
        } else {
            rightBarButtonItem = self.emptyStarButton
        }
        
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem]
    }
}

extension FriendViewController {
    @IBAction func touchUpFullStarButton(_ sender:UIBarButtonItem) {
        Person.removeBestFriend(self.friend) { isSuccess in
            if isSuccess {
                self.correctBarButtonState()
            }
        }
    }
    
    @IBAction func touchUpEmptyStarButton(_ sender:UIBarButtonItem) {
        Person.addBestFriend(self.friend) { isSuccess in
            if isSuccess {
                self.correctBarButtonState()
            }
        }
    }
}

extension FriendViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let friend : Person = self.friend else {
            return
        }
        
        self.correctBarButtonState()
        
        self.nameLabel.text = friend.name.full
        self.cellLabel.text = friend.cell
        self.nationalityLabel.text = friend.nationality
        self.imageView.image = self.thumbnailImage ?? placeHolderImage
        
        Request.image(friend.pictureURL.large) { image in
            self.imageView?.image = image
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if friend == nil {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
