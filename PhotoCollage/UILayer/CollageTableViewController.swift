//
//  CollageTableViewController.swift
//  PhotoCollage
//
//  Created by vit on 4/22/19.
//  Copyright © 2019 vit. All rights reserved.
//

import UIKit
import Netvit

// main table controller, with triple photo in a row
class CollageTableViewController: UITableViewController {

    private let photoStoreClass = PhotoStorage()
    private var pageNumber = 1
    private var tripleCounter = 0
    private var loadingStatusFlag = false
    private let resultsTableView = ResultsTableController()
    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // disable selection rows
        tableView.allowsSelection = false
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
    
    // row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.current.modelName == "iPhone 5" ? 145 : 175
    }
    
    // delete row with swipe
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            photoStoreClass.removeTriplet(atIndex: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // reuse cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CollageTableViewCell
        let triplet = tripleFromStorage(fromPhotoStorage: photoStoreClass.storagePhoto, withRow: indexPath.row)
        cell.updateCell(withTriplePhoto: triplet)
        cell.zoomDelegateBrige = self
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
   
    
    // MARK: — ZOOM STAFF
    //----------------------------------------
    private var basicFrame: CGRect?
    private var grayBackgroundView: UIView?
    private var basicImageView: UIImageView?
    
    // realized zoom logic
    func performZoomForImageView(_ basicImageView: UIImageView) {
        
        self.basicImageView = basicImageView
        basicImageView.isHidden = true
        // determine photo size and position
        basicFrame = basicImageView.superview?.convert(basicImageView.frame, to: nil)
        
        // create and set up zoomingView from basicFrame
        let zoomingView = UIImageView(frame: basicFrame!)
        zoomingView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        zoomingView.image = basicImageView.image
        zoomingView.isUserInteractionEnabled = true
        zoomingView.contentMode = .scaleAspectFill
        zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        // created and setting new window from main window
        if let keyWindow = UIApplication.shared.keyWindow {
            grayBackgroundView = UIView(frame: keyWindow.frame)
            grayBackgroundView?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            grayBackgroundView?.alpha = 0
            keyWindow.addSubview(grayBackgroundView!)
            keyWindow.addSubview(zoomingView)
            
            // animete window under zoom photo
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.grayBackgroundView?.alpha = 1
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: self.basicFrame!.height)
                zoomingView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    // handling zoom out
    @objc private func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            // animated zoom out
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                // zoom-frame reverse taked size of basic-frame
                zoomOutImageView.frame = self.basicFrame!
                self.grayBackgroundView?.alpha = 0
            }) { (completed: Bool) in
                // removed zoom-frame until next time
                zoomOutImageView.removeFromSuperview()
                self.basicImageView?.isHidden = false
            }
        }
    }
    

}
