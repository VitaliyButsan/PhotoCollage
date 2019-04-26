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

// table controller showing searching results
class ResultsTableController: UITableViewController, UISearchResultsUpdating {

    private let storagePhoto = PhotoStorage()
    private var pageNumber = 1
    private var searchingInput = ""
    private var loadingStatusFlag = false
    
    // view did load but not displayed yet
    override func viewDidLoad() {
        super.viewDidLoad()
        // disable selection rows
        tableView.allowsSelection = false
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
        // says, who perform delegated zoom logic
        cell.resultsTableController = self
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
    
    
    // MARK: — ZOOM STAFF
    // --------------------------------------------
    var basicFrame: CGRect?
    var blackBackgroundView: UIView?
    var basicImageView: UIImageView?
    
    // realized zoom logic
    func performZoomForImageView(_ basicImageView: UIImageView) {
        
        self.basicImageView = basicImageView
        basicImageView.isHidden = true
        //create new-frame on original photo place
        basicFrame = basicImageView.superview?.convert(basicImageView.frame, to: nil)
        
        // create and set up zooming view from basicFrame
        let zoomingView = UIImageView(frame: basicFrame!)
        zoomingView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        zoomingView.image = basicImageView.image
        zoomingView.isUserInteractionEnabled = true
        zoomingView.contentMode = .scaleAspectFill
        zoomingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        // created and setting new frame from main window
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingView)
            
            // animate frame under zoom photo
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                zoomingView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: self.basicFrame!.height)
                zoomingView.center = keyWindow.center
            }, completion: nil)
        }
    }
    
    // handling zoom out
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            // animated zoom out
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                // zoom-frame reverse taked size of basic-frame
                zoomOutImageView.frame = self.basicFrame!
                self.blackBackgroundView?.alpha = 0
            }) { (completed: Bool) in
                // removed zoom-frame until next time 
                zoomOutImageView.removeFromSuperview()
                self.basicImageView?.isHidden = false
            }
        }
    }
}

