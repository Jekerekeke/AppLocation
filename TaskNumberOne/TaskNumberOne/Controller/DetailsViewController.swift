//
//  DetailsViewController.swift
//  TaskNumberOne
//
//  Created by Максим Егоров on 24/04/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//
import UIKit
import CoreData

class DetailsViewController: UIViewController {
    @IBOutlet private var descriptionTextView: UITextView!
    @IBOutlet private var titleTextView: UITextView!
    private var taskTitle = ""
    private var taskDescription = ""
    private var isSaved = false
    private lazy var titleIsEmpty: Bool = {
        return self.titleTextView.text.isWord
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "More"
        titleTextView.text = taskTitle
        descriptionTextView.text = taskDescription
        navigationItem.setHidesBackButton(true, animated: false)
        let task = CoreDataService.instance.getTaskWithTitle(title: taskTitle)
        guard !task.isDone else {
            titleTextView.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            descriptionTextView.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            titleTextView.isEditable = false
            descriptionTextView.isEditable = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(exit))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(restore))
            titleTextView.delegate = self
            descriptionTextView.delegate = self
            if descriptionTextView.text.isEmpty { descriptionTextView.placeholder = "Description(0-1000 characters)" }
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(checkSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(exit))
        titleTextView.delegate = self
        descriptionTextView.delegate = self
        if descriptionTextView.text.isEmpty { descriptionTextView.placeholder = "Description(0-1000 characters)" }
    }
    
    func set(title: String, description: String) {
        self.taskTitle = title
        self.taskDescription = description
    }
}

private extension DetailsViewController {
    
    @objc func checkSave() {
        guard titleTextView.text.isWord else {
            showAlertWhenTitleIsEmpty()
            return
        }
        isSaved = true
        CoreDataService.instance.editTask(oldTitle: self.taskTitle, newTitle: self.titleTextView.text, specification: self.descriptionTextView.text)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func restore() {
        let task = CoreDataService.instance.getTaskWithTitle(title: taskTitle)
        task.isDone = false
        CoreDataService.instance.saveContext()
        titleTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        descriptionTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        titleTextView.isEditable = true
        descriptionTextView.isEditable = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(checkSave))
    }
    
    @objc func exit() {
        guard titleTextView.text.isWord else {
            showAlertWhenTitleIsEmpty()
            return
        }
        guard !isSaved else { return }
        guard titleTextView.text != taskTitle || descriptionTextView.text != taskDescription else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let alert = UIAlertController(title: "Do you want to save your task?", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let okAction = UIAlertAction(title: "Yes", style: .default) { _ in
            CoreDataService.instance.editTask(oldTitle: self.taskTitle, newTitle: self.titleTextView.text, specification: self.descriptionTextView.text)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        let cacnelAction = UIAlertAction(title: "No", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cacnelAction)
    }
    
    func showAlertWhenTitleIsEmpty() {
        let alert = UIAlertController(title: "Title can't be empty", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okAction)
    }
}

extension DetailsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView.tag == 1 else {
            return textView.text.count + (text.count - range.length) <= 1000
        }
        return textView.text.count + (text.count - range.length) <= 100
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView.tag == 1 else {
            textView.placeholder = "Description(0-1000 characters)"
            return
        }
        textView.placeholder = "Title(0-100 characters)"
    }
}
