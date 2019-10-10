//
//  JoinGroupController.swift
//  Vampire
//
//  Created by burak kaya on 10/10/2019.
//

import UIKit

class JoinGroupController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userId: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userId.text = "\(currentUser.id)"
        self.userName.text = currentUser.name
    }
    
    @IBAction func joinGroup(_ sender: Any) {
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
