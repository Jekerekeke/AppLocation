//
//  CreationViewController.swift
//  TaskNumberOne
//
//  Created by Максим Егоров on 25/04/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//
import UIKit
import CoreData

class CreationViewController: UIViewController {
    @IBOutlet private var titleTextView: UITextView!
    @IBOutlet private var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create task"
        self.navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(checkSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        titleTextView.delegate = self
        descriptionTextView.delegate = self
        titleTextView.placeholder = "Title(0-100 characters)"
        descriptionTextView.placeholder = "Description(0-1000 characters)"
    }
}

private extension CreationViewController {
    @objc func checkSave() {
        guard titleTextView.text.isWord else {
            showAlertWhenTitleIsEmpty()
            return
        }
        CoreDataService.instance.createTask(title: titleTextView.text, specification: descriptionTextView.text)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlertWhenTitleIsEmpty() {
        let alert = UIAlertController(title: "Title can't be empty", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okAction)
    }
}

extension CreationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView.tag == 3 else {
            return textView.text.count + (text.count - range.length) <= 1000
        }
        return textView.text.count + (text.count - range.length) <= 100
    }
}
