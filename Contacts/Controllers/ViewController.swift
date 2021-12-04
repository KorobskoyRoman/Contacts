//
//  ViewController.swift
//  Contacts
//
//  Created by Roman Korobskoy on 30.11.2021.
//

import UIKit

class ViewController: UIViewController {
    
    var storage: ContactStorageProtocol! 

    @IBOutlet var tableView: UITableView!
    
    var contacts: [ContactProtocol] = [] {
        didSet {
            contacts.sort{ $0.title < $1.title }
            storage.save(contacts: contacts)
        }
    } //можно заменить на экземпляр структуры
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContacts()
        storage = ContactStorage() as ContactStorageProtocol
        loadContacts()
    }
    
    private func loadContacts() {
        contacts = storage.load()
    }
    
    @IBAction func showNewContactAlert() {
        let alertController = UIAlertController(title: "Создание нового контакта", message: "Введите имя и телефон", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Имя"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Телефон"
        }
        let createButton = UIAlertAction(title: "Создать", style: .default) { _ in
            guard let contactName = alertController.textFields?[0].text,
                  let contactPhone = alertController.textFields?[1].text
            else {return}
            
            let contact = Contacts(title: contactName, phone: contactPhone)
            self.contacts.append(contact)
            self.tableView.reloadData()
        }
        let cancelButton = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelButton)
        alertController.addAction(createButton)
        
        self.present(alertController, animated: true, completion: nil)
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") {
            print("Используем старую ячейку для строки с индексом \(indexPath.row)")
            cell = reuseCell
        } else {
            print("Создаем новую ячейку для строки с индексом \(indexPath.row)")
            cell = UITableViewCell(style: .default, reuseIdentifier: "MyCell")
        }
        configure(cell: &cell, for: indexPath)
        return cell
    }
    
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        var configuration = cell.defaultContentConfiguration()
        configuration.text = contacts[indexPath.row].title
        configuration.secondaryText = contacts[indexPath.row].phone
        cell.contentConfiguration = configuration
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionDelete = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.contacts.remove(at: indexPath.row)
            tableView.reloadData()
        }
        let actions = UISwipeActionsConfiguration(actions: [actionDelete])
        return actions
    }
    //сделать функцию для изменения
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("edit row swap!") //del
        return nil //del
    }
}
