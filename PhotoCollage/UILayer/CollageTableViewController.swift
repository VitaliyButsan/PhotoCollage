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
    private var tripleCounter = 0
    private var loadingStatusFlag = false
    private let resultsTableView = ResultsTableController()
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // set up search controller
        setUpSearchController()
        // call refresh control
        refreshControl()
        // call getPhoto func
        getPhoto()
    }
    
    // define getPhoto func
    @objc private func getPhoto() {
        // if pages not over
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
                self.refreshControl?.endRefreshing()
                self.loadingStatusFlag = true
            }
            
            pageNumber += 1
            
        } else {
            // if pages is over
            if loadingStatusFlag == false {
                alert(withTitle: "No more photos!", withMessage: "", titleForActionButton: "Ok")
            }
        }
    }

    private func receiveNewPage() {
        getPhoto()
    }
    
    // set up search controller
    private func setUpSearchController() {
        searchController = UISearchController(searchResultsController: resultsTableView)
        searchController.searchResultsUpdater = resultsTableView
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // set up pull to refresh func
    private func refreshControl() {
        // clearing old photos before refresh
        photoStoreClass.clearStoragePhoto()
        // set refreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
        refreshControl.addTarget(self, action: #selector(getPhoto), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // take three links from photo storage
    private func tripleFromStorage(fromPhotoStorage storage: [PhotoDetails], withRow currentRow: Int) -> [URL] {
        var triplePhoto: [PhotoDetails] = []
        var tripleUrl: [URL] = []
        // index for walk through array
        let currentIndex = currentRow * 3
        
        if currentRow < storage.count {
            // taken out three photo object
            let sliseArray = storage[currentIndex ..< currentIndex + 3]
            triplePhoto = Array(sliseArray)
            // taken links from photo objects
            for photoItem in triplePhoto {
                tripleUrl.append(photoItem.urls.small)
            }
        }
        
        return tripleUrl
    }
    
    // set up alert handler
    private func alert(withTitle title: String, withMessage message: String, titleForActionButton buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
        
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoStoreClass.storagePhoto.count / 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CollageTableViewCell
        let triplet = tripleFromStorage(fromPhotoStorage: photoStoreClass.storagePhoto, withRow: indexPath.row)
        cell.updateCell(withTriplePhoto: triplet)
        return cell
    }
    
    // pagination pages
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isBottom = (tableView.contentOffset.y + tableView.frame.size.height) < tableView.contentSize.height
        if !isBottom, scrollView.isDragging, loadingStatusFlag, !photoStoreClass.storagePhoto.isEmpty {
            loadingStatusFlag = false
            receiveNewPage()
        }
        
        
    }
    


}
