//
//  CollageTableViewController.swift
//  PhotoCollage
//
//  Created by vit on 4/22/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Netvit

class CollageTableViewController: UITableViewController {

    private let photoStoreClass = PhotoStorage()
    private var pageNumber = 1
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // call refresh control
        refreshControl()
        // call getPhoto func
        getPhoto()
    }
    
    // define getPhoto func
    @objc private func getPhoto() {
        if pageNumber <= 10 {
            Netvit.getPhotos(onPage: pageNumber, withLimit: 30) { result in
                switch result {
                case .success(let receivedPhotos):
                    self.photoStoreClass.storagePhoto += receivedPhotos
                    self.tableView.reloadData()
                case .failure( _ ):
                    // if data not received
                    self.alert(withTitle: "Data not received!", withMessage: "Try pull down to refresh.", titleForActionButton: "Ok")
                    self.tableView.reloadData()
                }
                // stop refresh control
                self.tableView.refreshControl?.endRefreshing()
            }
            
            pageNumber += 1
            
        } else {
            // if pages is over
            alert(withTitle: "No more photos!", withMessage: "", titleForActionButton: "Ok")
        }
    }

    // set up pull to refresh func
    private func refreshControl() {
        photoStoreClass.clearStoragePhoto()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
        refreshControl.addTarget(self, action: #selector(getPhoto), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // set up alert handler
    private func alert(withTitle title: String, withMessage message: String, titleForActionButton buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
        
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoStoreClass.storagePhoto.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        
        // pagination cells
        if indexPath.row == photoStoreClass.storagePhoto.count - 1 {
            getPhoto()
        }
        
        return cell
    }

}
