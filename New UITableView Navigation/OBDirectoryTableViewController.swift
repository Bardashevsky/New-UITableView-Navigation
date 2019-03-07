//
//  OBDirectoryTableViewController.swift
//  New UITableView Navigation
//
//  Created by Oleksandr Bardashevskyi on 3/6/19.
//  Copyright © 2019 Oleksandr Bardashevskyi. All rights reserved.
//

import UIKit

class OBDirectoryTableViewController: UITableViewController {
    
    var path = String()
    var contents = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @objc func actionBackToRooT() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nc = self.navigationController?.viewControllers {
            if nc.count > 1 {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Back to root", style: UIBarButtonItem.Style.plain, target: self, action: #selector(actionBackToRooT))
            }
        }
        print("path = \(self.path)")
        print("ViewControllers on stack = \(self.navigationController?.viewControllers.count ?? 0)")
        print("index on stack = \(self.navigationController?.viewControllers.index(of: self) ?? 0)")
        
    }
    
    deinit {
        print("Controller with \(self.path) path has been deallocated")
    }
    
    //MARK: - Init TableView Controller
    func initWithFolderPath(path: String) -> UITableViewController {
        
        self.tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.grouped)
        
        self.path = path
        let fm = FileManager.default
        
        do {
            self.contents = try fm.contentsOfDirectory(atPath: self.path)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        title = (self.path as NSString).lastPathComponent
        return self
    }
    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contents.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        
        let fileName = self.contents[indexPath.row]
        
        cell?.textLabel?.text = fileName
        
        if isDirectoryAtIndexPath(indexPath: indexPath).boolValue == true {
            cell?.imageView?.image = UIImage(named: "folder")
        } else if fileName.hasSuffix(".mp3") {
            cell?.imageView?.image = UIImage(named: "music")
        } else {
            cell?.imageView?.image = UIImage(named: "file")
        }
        
        return cell!
    }
    //MARK: - isDirectory Method
    func isDirectoryAtIndexPath(indexPath: IndexPath) -> ObjCBool {
        
        let fileName = self.contents[indexPath.row]
        let filePath = (self.path as NSString).appendingPathComponent(fileName)
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
        
        
        return isDirectory
    }
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let fileName = self.contents[indexPath.row]
        let filePath = (self.path as NSString).appendingPathComponent(fileName)
        
        if isDirectoryAtIndexPath(indexPath: indexPath).boolValue == true {
            
            let vc = OBDirectoryTableViewController()
            self.navigationController?.pushViewController(vc.initWithFolderPath(path: filePath), animated: true)
            
        } else if filePath.hasSuffix(".mp3") {
            
            let vc = PlayerViewController()
            self.navigationController?.pushViewController(vc.initWithPath(path: filePath), animated: true)
        }
    }
}
