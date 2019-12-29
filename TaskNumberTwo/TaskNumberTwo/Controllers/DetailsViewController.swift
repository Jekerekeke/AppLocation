//
//  DetailsViewController.swift
//  TaskNumberTwo
//
//  Created by Максим Егоров on 02/05/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//
import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet private var descriptionTextView: UITextView!
    @IBOutlet private var titleTextView: UITextView!
    private var taskTitle = ""
    private var taskDescription = ""
    private var isSaved = false
    private var isDone = false
    private lazy var titleIsEmpty: Bool = {
        return self.titleTextView.text.isWord
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "More"
        titleTextView.text = taskTitle
        descriptionTextView.text = taskDescription
        navigationItem.setHidesBackButton(true, animated: false)
       // let task = CoreDataService.instance.getTaskWithTitle(title: taskTitle)
        guard !isDone else {
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
    
    func set(title: String, description: String, isDone: Bool) {
        self.taskTitle = title
        self.taskDescription = description
        self.isDone = isDone
    }
}

private extension DetailsViewController {
    
    @objc func checkSave() {
        guard titleTextView.text.isWord else {
            showAlertWhenTitleIsEmpty()
            return
        }
        isSaved = true
        ViewModel.instance.editTask(oldTitle: taskTitle, title: titleTextView.text, description: descriptionTextView.text)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func restore() {
        let task = ViewModel.instance.getTask(title: taskTitle)
        ViewModel.instance.changeFlagOfDone(task: task)
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
            ViewModel.instance.editTask(oldTitle: self.taskTitle, title: self.titleTextView.text, description: self.descriptionTextView.text)
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

