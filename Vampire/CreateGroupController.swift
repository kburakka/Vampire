//
//  OperationController.swift
//  Vampire
//
//  Created by burak kaya on 10/10/2019.
//

import UIKit
import Backendless

class CreateGroupController: UIViewController {
    
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var groupName: UITextField!
    
    private var groupStore: DataStoreFactory = Backendless.shared.data.of(Group.self)
    private var userStore: DataStoreFactory = Backendless.shared.data.of(User.self)

    override func viewDidLoad() {
        super.viewDidLoad()
        groupName.attributedPlaceholder = NSAttributedString(string: "Please enter group name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        groupName.textColor = UIColor.white
        self.userId.text = "\(currentUser.id)"
        self.userName.text = currentUser.name
    }
    
    @IBAction func createGroup(_ sender: Any) {
        let group = Group()
        group.name = groupName.text
        
        groupStore.save(entity: group, responseHandler: { savedGroup in
            if let savedGroup = savedGroup as? Group {
                currentGroup = savedGroup
                
                currentUser.groupId = savedGroup.id
                
                self.userStore.update(entity: currentUser, responseHandler: { savedUser in
                    if let yaya = savedUser as? User {
                        print(yaya)
                    }
                    let storyboard = UIStoryboard.init(name:"Main", bundle: nil)
                    let view = storyboard.instantiateViewController(withIdentifier: "group") as! UITableViewController
                    view.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(view, animated: true)
                }, errorHandler: { fault in
                    self.showErrorAlert(fault)
                })
            }
        }, errorHandler: { fault in
            self.showErrorAlert(fault)
        })
    }
    
//    func checkGroup(){
//         let queryBuilder = DataQueryBuilder()
//         queryBuilder.setWhereClause(whereClause: "uuid = '\(uuid!)'")
//
//         userStore.find(queryBuilder: queryBuilder, responseHandler: { [weak self] foundUser in
//             if let foundUser = foundUser as? [User] {
//                 if foundUser.count == 1{
//                     currentUser = foundUser[0]
//                     self?.toOperationView()
//                 }
//             }
//             }, errorHandler: { [weak self] fault in
//                 self?.showError(fault: fault)
//         })
//     }
    
    func showErrorAlert(_ fault: Fault) {
        let alert = UIAlertController(title: String(format: "Error %@", fault.faultCode), message: fault.message, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismissButton)
        present(alert, animated: true, completion: nil)
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
