//
//  ViewController.swift
//  Todo-App
//
//  Created by Superdev on 18/09/2017.
//  Copyright © 2017 Superdev. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var lists : Results<Todo>!
    var filtered:Results<Todo>!
    
    var isEditingMode = false
    var searchActive = false
    
    var currentCreateAction:UIAlertAction!
    
    @IBOutlet weak var todoListTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readTodosAndUpdateUI()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (searchActive) {
            if let listsTodo = filtered{
                return listsTodo.count
            }
        } else {
            if let listsTodo = lists{
                return listsTodo.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell")
        if (searchActive) {
            let list = filtered[indexPath.row]
            cell?.textLabel?.text = list.name
            cell?.detailTextLabel?.text = "Priority \(list.priority)"
            
        } else {
            let list = lists[indexPath.row]
            cell?.textLabel?.text = list.name
            cell?.detailTextLabel?.text = "Priority \(list.priority)"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            // Delete
            let listToBeDeleted = self.lists[indexPath.row]
            try! uiRealm.write{
                uiRealm.delete(listToBeDeleted)
                self.readTodosAndUpdateUI()
            }
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Edit
            let listToBeUpdated = self.lists[indexPath.row]
            self.displayAlertToAddTodo(listToBeUpdated)
            
        }
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        self.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
        self.searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (lists == nil) {
            return
        }
        
        let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", self.searchBar.text!)
        self.filtered = self.lists!.filter(searchPredicate)
        
        if(filtered.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.todoListTableView.reloadData()
    }
    
    // IBAction
    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        
        if (sender.selectedSegmentIndex == 0) {
            // Priority
            self.lists = self.lists.sorted(byKeyPath: "priority")
            
        } else {
            // Date
            self.lists = self.lists.sorted(byKeyPath: "createdAt", ascending:false)
        }
        self.todoListTableView.reloadData()
    }
    
    @IBAction func didClickOnEditButton(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.todoListTableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func didClickOnAddButton(_ sender: UIBarButtonItem) {
        
        displayAlertToAddTodo(nil)
    }
    
    func readTodosAndUpdateUI(){
        self.lists = uiRealm.objects(Todo.self)
        self.lists = self.lists.sorted(byKeyPath: "priority")
        self.todoListTableView.setEditing(false, animated: true)
        self.todoListTableView.reloadData()
    }
    
    func listNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    func displayAlertToAddTodo(_ updatedList:Todo!){
        
        var title = "New Todo"
        var doneTitle = "Create"
        if updatedList != nil{
            title = "Update Todo"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Input the name and priority", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let listName = alertController.textFields?.first?.text
            let priority = alertController.textFields?.last?.text
            if (listName == "" || priority == "") {
                let alert = UIAlertController(title: "Error", message: "The name and priority can't be nil", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if updatedList != nil{
                // update mode
                try! uiRealm.write{
                    updatedList.name = listName!
                    updatedList.priority = Int((priority! as NSString).intValue)
                    self.readTodosAndUpdateUI()
                }
                
            } else{
                let newTodo = Todo()
                newTodo.name = listName!
                newTodo.priority = Int((priority! as NSString).intValue)
                
                try! uiRealm.write{
                    uiRealm.add(newTodo)
                    self.readTodosAndUpdateUI()
                }
            }
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Name"
            textField.addTarget(self, action: #selector(ViewController.listNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedList != nil{
                textField.text = updatedList.name
            }
        }
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Priority"
            textField.addTarget(self, action: #selector(ViewController.listNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedList != nil{
                textField.text = String(updatedList.priority)
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}

