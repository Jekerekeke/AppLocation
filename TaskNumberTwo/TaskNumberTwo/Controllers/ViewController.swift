//
//  ViewController.swift
//  TaskNumberTwo
//
//  Created by Максим Егоров on 02/05/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private let realmService = RealmService()
    private var tasks: Results<Task>! {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private let identifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCreationController))
        tasks = realmService.getAll()
        ViewModel.instance.onTasksChanged = { [unowned self] in
            self.tasks = $0
        }
    }
}

private extension ViewController {
    @objc func showCreationController() {
        guard let intent = storyboard?.instantiateViewController(withIdentifier: "CreationViewController") as? CreationViewController else {return}
        self.navigationController?.pushViewController(intent, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        cell.detailTextLabel?.text = formatter.string(from: task.date)
        cell.accessoryType = .detailDisclosureButton
        guard !task.isDone else {
            cell.textLabel?.text = task.title + "✅"
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let intent = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else { return }
        navigationController?.pushViewController(intent, animated: true)
        let task = tasks[indexPath.row]
        intent.set(title: task.title, description: task.specification ?? "", isDone: task.isDone)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let task = tasks[indexPath.row]
        
        let doneAction = UIContextualAction(style: .normal, title:  "Done", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            ViewModel.instance.changeFlagOfDone(task: task)
            success(true)
        })
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        let restoreAction = UIContextualAction(style: .normal, title:  "Restore", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            ViewModel.instance.changeFlagOfDone(task: task)
            success(true)
        })
        guard !task.isDone else {
            return UISwipeActionsConfiguration(actions: [restoreAction])
        }
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let task = tasks[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            ViewModel.instance.deleteTask(task: task)
            success(true)
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

