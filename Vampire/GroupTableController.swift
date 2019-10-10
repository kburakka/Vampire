//
//  GroupTableController.swift
//  Vampire
//
//  Created by burak kaya on 10/10/2019.
//

import UIKit
import Backendless

class GroupTableController: UITableViewController {

    private var userStore: DataStoreFactory = Backendless.shared.data.of(User.self)
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = currentGroup.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Play", style: .done, target: nil, action: #selector(play))
        checkUser()
    }

    @objc func play(){
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    func checkUser(){
        let queryBuilder = DataQueryBuilder()
        queryBuilder.setWhereClause(whereClause: "groupId = '\(currentGroup.id)'")
        
        userStore.find(queryBuilder: queryBuilder, responseHandler: { [weak self] foundUser in
            if let foundUser = foundUser as? [User] {
                self?.users = foundUser
                self?.tableView.reloadData()
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
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
