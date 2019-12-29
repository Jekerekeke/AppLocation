//
//  ViewController.swift
//  TaskNumberOne
//
//  Created by Максим Егоров on 23/04/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//
import UIKit
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet private var tableView: UITableView!
    var array: [IndexPath] = []
    var fetchedResultsController = CoreDataService.instance.fetchData(entityName: "Tasks", keyForSort: "isDone")
    private let identifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCreationController))
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let task = CoreDataService.instance.getTaskWithIndexPath(indexPath: indexPath)
                let cell = tableView.cellForRow(at: indexPath)
                cell!.textLabel?.text = task.title
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

private extension ViewController {
    @objc func showCreationController() {
        guard let intent = storyboard?.instantiateViewController(withIdentifier: "CreationViewController") as? CreationViewController else {return}
        self.navigationController?.pushViewController(intent, animated: true)
    }
    
    func getDateForCell(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataService.instance.getDataBaseSize()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let task = CoreDataService.instance.getTaskWithIndexPath(indexPath: indexPath)
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = self.getDateForCell(date: task.date ?? Date())
        cell.tintColor = UIColor.blue
        cell.accessoryType = .detailDisclosureButton
        guard task.isDone else {return cell}
        cell.textLabel?.text = task.title! + "✅"
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let intent = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else {return}
        self.navigationController?.pushViewController(intent, animated: true)
        let task = CoreDataService.instance.getTaskWithIndexPath(indexPath: indexPath)
        intent.set(title: task.title ?? "", description: task.specification ?? "")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let task = CoreDataService.instance.getTaskWithIndexPath(indexPath: indexPath)
        
        let doneAction = UIContextualAction(style: .normal, title:  "Done", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            task.isDone = true
            CoreDataService.instance.saveContext()
            success(true)
        })
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        let restoreAction = UIContextualAction(style: .normal, title:  "Restore", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            task.isDone = false
            CoreDataService.instance.saveContext()
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
        let deleteAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let task = CoreDataService.instance.getTaskWithIndexPath(indexPath: indexPath)
            CoreDataService.instance.managedObjectContext.delete(task)
            CoreDataService.instance.saveContext()
            success(true)
        })
        return UISwipeActionsConfiguration(actions: [deleteAction])    }
}
