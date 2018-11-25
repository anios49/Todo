//
//  ViewController.swift
//  Todo
//
//  Created by Animesh Mishra on 22/11/18.
//  Copyright © 2018 Animesh Mishra. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadData()
//        let newItem = Item()
//        newItem.item = "First Item"
//        itemArray.append(newItem)
//
//        let newItem2 = Item()
//        newItem2.item = "First Item"
//        itemArray.append(newItem2)
//
//        let newItem3 = Item()
//        newItem3.item = "First Item"
//        itemArray.append(newItem3)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].item
        let item = itemArray[indexPath.row]
        cell.accessoryType = item.done ? .checkmark : .none
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if itemArray[indexPath.row].done == false {
            itemArray[indexPath.row].done = true
        }
        else {
            itemArray[indexPath.row].done = false
        }
        saveData()
    }
    
    fileprivate func saveData() {
        let encoder = PropertyListEncoder()
        do{
            let dataEncode = try encoder.encode(itemArray)
            try dataEncode.write(to:path!)
        }
        catch{
            print("Error")
        }
        self.tableView.reloadData()
    }
    
    fileprivate func loadData() {
        if let data = try? Data(contentsOf: path!) {
            let decoder = PropertyListDecoder()
            do {
               itemArray = try decoder.decode([Item].self, from: data)
            }
            catch {
                print("Error")
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add To Do Task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if (!(textField.text?.isEmpty)!) {
                if let data = textField.text {
                    let newItem = Item()
                    newItem.item = data
                    self.itemArray.append(newItem)
                }
                self.saveData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Item Name"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

