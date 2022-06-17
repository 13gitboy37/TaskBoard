//
//  ViewController.swift
//  TaskBoard
//
//  Created by Никита Мошенцев on 14.06.2022.
//

import UIKit

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Private properties
    private let tableView = UITableView()
    
    //MARK: - Properties
    var parentVC: TaskViewController? {
        didSet {
            
            guard let parentVC = parentVC, !parentVC.isRootVC else { return }
            if let currentTask = parentVC.currentTask  {
                currentTask.subtasks = parentVC.tasks
            if let index = parentVC.parentVC?.tasks.firstIndex(of: currentTask) {
                parentVC.parentVC?.tasks[index] = currentTask
                }
            }
        }
    }
    
    var isRootVC: Bool = true
    var currentTask: Task?
    var tasks = [Task]() {
        didSet {
            if let currentTask = currentTask {
                currentTask.subtasks = tasks
                if let index = parentVC?.tasks.firstIndex(of: currentTask) {
                parentVC?.tasks[index] = currentTask
                    }
                }
            guard isRootVC else {
                guard let parentVC = parentVC, parentVC.isRootVC else { return }
                Session.shared.update(tasks: parentVC.tasks)
                return
            }
            Session.shared.update(tasks: tasks)
        }
    }
    
    //MARK: - Init
    init(tasks: [Task]) {
           self.tasks = tasks
           super.init(nibName: nil, bundle: nil)
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
       }
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    //MARK: - Methods
    func initialSetup() {
        let safeArea = view.layoutMarginsGuide
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "taskCell")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTasksButtonTap))
        guard isRootVC else { return }
    }
    
    @objc func addTasksButtonTap() {
        alertAddTask(title: "Добавление задачи", placeholder: "Введите название задачи") { [self] (text) in
            var indexPath = IndexPath(row: 0, section: 0)
            tableView.beginUpdates()
            if isRootVC {
            tasks.append(Task(name: text))
            indexPath = IndexPath(row: tasks.count - 1, section: 0)
            } else {
                for index in 0...(parentVC?.tasks.count ?? 0) - 1 {
                    if parentVC?.tasks[index].name == self.title ?? "" {
                        parentVC?.tasks[index].subtasks.append(Task(name: text))
                        tasks.append(Task(name: text))
                        indexPath = IndexPath(row: tasks.count - 1, section: 0)
                }
            }
            }
            
            tableView.insertRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    private func alertAddTask (title: String, placeholder: String, completionHandler: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) { (action) in
            
            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else { return }
            completionHandler(text)
        }
        
        alertController.addTextField { (tf) in
            tf.placeholder = placeholder
        }
        
        let alertCancel = UIAlertAction(title: "Отмена", style: .default) { (_) in
        }
        
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }

    
    //MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return tasks.count
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var cell = tableView.dequeueReusableCell(withIdentifier: "taskCell")
        else { return UITableViewCell() }
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "taskCell")
        cell.detailTextLabel?.isEnabled = true
        let currentTask = tasks[indexPath.row]
            cell.textLabel?.text = currentTask.name
        if currentTask.subtasks == [] || currentTask.subtasks.count >= 5 {
            cell.detailTextLabel?.text = "\(currentTask.subtasks.count) задач"
            } else if currentTask.subtasks.count == 1 {
                cell.detailTextLabel?.text = "\(currentTask.subtasks.count) задача"
            } else if currentTask.subtasks.count < 5 {
                cell.detailTextLabel?.text = "\(String(describing: currentTask.subtasks.count)) задачи"
            }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectTask = tasks[indexPath.row]
        let childVC = TaskViewController(tasks: selectTask.subtasks)
        childVC.isRootVC = false
        childVC.parentVC = self
        childVC.title = selectTask.name
        navigationController?.pushViewController(childVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              tasks.remove(at: indexPath.row)
              tableView.deleteRows(at: [indexPath], with: .fade)
          }
      }
}

    


