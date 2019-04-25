//
//  ResultsTableController.swift
//  PhotoCollage
//
//  Created by vit on 4/24/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Netvit
import SDWebImage

class ResultsTableController: UITableViewController, UISearchResultsUpdating {

    private let storagePhoto = PhotoStorage()
    private var pageNumber = 1
    private var searchingInput = ""
    private var loadingStatusFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // register the cell
        tableView.register(ResultsTableViewCell.self, forCellReuseIdentifier: "SearchResultsCell")
    }

    // define search photo func
    private func searchPhoto(viaName inputName: String) {
        // if pages not over
        if pageNumber <= 10 {
            Netvit.searchPhotos(onPage: pageNumber, viaName: inputName) { result in
                switch result {
                case .success(let allSearchingPhotos):
                    self.storagePhoto.searchingPhotoStorage += allSearchingPhotos.results
                    self.tableView.reloadData()
                case .failure( _ ):
                    self.alert(withTitle: "Data Not Received!", withMessage: "", titleForActionButton: "Ok")
                }
                // status flag for pagination
                self.loadingStatusFlag = true
            }
            
            pageNumber += 1
            
        } else {
            // if pages is over
            if loadingStatusFlag == false {
                self.alert(withTitle: "Searching is over!", withMessage: "", titleForActionButton: "Ok")
            }
        }
    }
    
    // set up alert
    private func alert(withTitle alertTitle: String, withMessage message: String, titleForActionButton buttonTitle: String) {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // get new page
    private func receiveNewPage() {
        searchPhoto(viaName: searchingInput)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storagePhoto.searchingPhotoStorage.count
    }
    
    // delete row with swipe
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            storagePhoto.searchingPhotoStorage.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // reuse cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultsCell", for: indexPath) as! ResultsTableViewCell
        cell.updateCell(withPhtoURL: storagePhoto.searchingPhotoStorage[indexPath.row].urls.small)
        return cell
    }

    // pagination searching pages
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isBottom = (tableView.contentOffset.y + tableView.frame.size.height) < tableView.contentSize.height
        if !isBottom, scrollView.isDragging, loadingStatusFlag, !storagePhoto.searchingPhotoStorage.isEmpty {
            loadingStatusFlag = false
            receiveNewPage()
        }
    }
    
    
    // MARK: — UISearchResultsUpdating protocol
    
    // called when user input text to search field
    func updateSearchResults(for searchController: UISearchController) {
        searchingInput = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
        // start searching only if no less than 3 characters was input
        if searchingInput.count > 3 {
            pageNumber = 1
            loadingStatusFlag = true
            storagePhoto.clearSearchingPhoto()
            self.tableView.reloadData()
            // new searching request
            searchPhoto(viaName: searchingInput)
        }
    }
}

