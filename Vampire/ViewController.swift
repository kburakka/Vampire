 
 import UIKit
 import Backendless
 
 @objcMembers class User: NSObject {
    var id = Int()
    var uuid: String?
    var name: String?
    var groupId = Int()
 }
 @objcMembers class Group: NSObject {
    var id = Int()
    var name: String?
 }

 var currentUser = User()
 var currentGroup = Group()

 class ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userJoin: UIButton!
    
    private var userList = [User]()
    let uuid = UIDevice.current.identifierForVendor?.uuidString

    override func viewDidLoad() {
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Please enter your name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        nameTextField.textColor = UIColor.white
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkUser()
    }
    private var userStore: DataStoreFactory = Backendless.shared.data.of(User.self)

    func checkUser(){
        let queryBuilder = DataQueryBuilder()
        queryBuilder.setWhereClause(whereClause: "uuid = '\(uuid!)'")
        
        userStore.find(queryBuilder: queryBuilder, responseHandler: { [weak self] foundUser in
            if let foundUser = foundUser as? [User] {
                if foundUser.count == 1{
                    currentUser = foundUser[0]
                    self?.toOperationView()
                }
            }
            }, errorHandler: { [weak self] fault in
                self?.showError(fault: fault)
        })
    }
    
    func getUser() {
         let queryBuilder = DataQueryBuilder()
         queryBuilder.setPageSize(pageSize: 100)
         queryBuilder.setSortBy(sortBy: ["created"])

        userStore.find(queryBuilder: queryBuilder, responseHandler: { [weak self] foundUser in
             if let foundUser = foundUser as? [User] {
                self?.userList = foundUser
            }
         }, errorHandler: { [weak self] fault in
             self?.showError(fault: fault)
         })
     }
    
    func showError(fault: Fault) {
          let alert = UIAlertController(title: "Error", message: fault.message ?? "An error occurred", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
          self.present(alert, animated: true, completion: nil)
      }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
//        if ((textField.text?.count)! > 0) {
//            updateButton.isEnabled = true
//        }
//        else {
//            updateButton.isEnabled = false
//        }
    }
    @IBAction func userJoin(_ sender: Any) {
        createUser()
    }
    
    func showErrorAlert(_ fault: Fault) {
        let alert = UIAlertController(title: String(format: "Error %@", fault.faultCode), message: fault.message, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismissButton)
        present(alert, animated: true, completion: nil)
    }
    
    func toOperationView(){
        let storyboard = UIStoryboard.init(name:"Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "operationView") as! UITabBarController
        view.modalPresentationStyle = .fullScreen
        self.present(view, animated: true, completion: nil)
    }
    
    
    func createUser(){
        if let name = nameTextField.text{
            let user = User()
            user.name = name
            user.uuid = uuid!
            
            userStore.save(entity: user, responseHandler: { savedUser in
                if let _ = savedUser as? User {
                    self.checkUser()
                }
            }, errorHandler: { fault in
                self.showErrorAlert(fault)
            })
        }else{
            print("hata")
        }
    }
    
    @IBAction func pressedUpdate(_ sender: Any) {
//        if let property = changePropertyValueTextField.text {
//            testObject!["foo"] = property
//            dataStore?.update(entity: testObject, responseHandler: { updatedTestObject in
//            }, errorHandler: { fault in
//                self.showErrorAlert(fault)
//            })
//        }
//        changePropertyValueTextField.text = ""
//        updateButton.isEnabled = false
    }
 }
                
