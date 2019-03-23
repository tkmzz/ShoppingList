//
//  ShoppingTableViewController.swift
//  BoringSSL-GRPC
//
//  Created by Usuário Convidado on 23/03/19.
//

import UIKit
import Firebase

class ShoppingTableViewController: UITableViewController {

    let collection = "shoppingList"
    var firestoreListener: ListenerRegistration!
    var firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        var firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    var shoppingList: [ShoppingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Auth.auth().currentUser?.displayName
        listItems()
    }
    
    func listItems() {
        
        firestoreListener = firestore.collection(collection).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            if error != nil {
                print(error!)
            }
            
            guard let snapshot = snapshot else {return}
            print("Total de mudanças: ", snapshot.documentChanges.count)
            
            
            if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                self.showItems(snapshot: snapshot)
            }
        }
    }
    
    func showItems(snapshot: QuerySnapshot) {
        
        shoppingList.removeAll()
        for document in snapshot.documents{
            let data = document.data()
            if let name = data["name"] as? String, let quantity = data["quantity"] as? Int {
                let shoppintItem = ShoppingItem(name: name, quantity: quantity, id: document.documentID)
                shoppingList.append(shoppintItem)
            }
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let shoppintItem = shoppingList[indexPath.row]
        cell.textLabel?.text = shoppintItem.name
        cell.detailTextLabel?.text = "\(shoppintItem.quantity)"
        return cell
    }

}
