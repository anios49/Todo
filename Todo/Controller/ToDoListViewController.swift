//
//  ViewController.swift
//  Todo
//
//  Created by Animesh Mishra on 22/11/18.
//  Copyright © 2018 Animesh Mishra. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Item.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: Category? {
        didSet{
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
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
        do {
            try context.save()
        }
        catch{
            print("Error")
        }
        self.tableView.reloadData()
    }
    
    fileprivate func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate? = nil) {
        let basicPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", (selectedCategory?.name)!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [basicPredicate,additionalPredicate])
        }
        else{
            request.predicate = basicPredicate
        }
        
        do {
            itemArray  = try context.fetch(request)
        }
        catch {
            print("Error")
        }
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add To Do Task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if (!(textField.text?.isEmpty)!) {
                if let data = textField.text {
                    let newItem = Item(context: self.context)
                    newItem.title = data
                    newItem.parentCategory = self.selectedCategory
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

//MARK: - Search Bar Delegate

extension ToDoListViewController:UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadData(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
