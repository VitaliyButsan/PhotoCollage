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

    let photoStore = PhotoStorage()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // call getPhoto func
        getPhoto()
    }
    
    // define getPhoto func
    private func getPhoto() {
        Netvit.getPhotos(onPage: 1, withLimit: 5) { result in
            switch result {
            case .success(let photos):
                self.photoStore.storagePhoto = photos
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoStore.storagePhoto.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"

        return cell
    }

}
