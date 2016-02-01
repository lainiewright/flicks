//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Lainie Wright on 1/10/16.
//  Copyright © 2016 lainiewright. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var errorImage: UIImageView!
    @IBOutlet weak var errorView: UIView!
    
    
    var movies: [NSDictionary]?
    
    var filteredData: [NSDictionary]!
    var searchActive: Bool! = false
    
    var endpoint: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsSelection = true
        
        errorImage.image = UIImage(named: "network_error")
        errorView.hidden = true
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        filteredData = movies
        
        // Flow Layout properties
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)

        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.collectionView.reloadData()
                    }
                } else {
                    self.errorView.hidden = false
                }
        });
        task.resume()
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let totalwidth = collectionView.bounds.size.width;
        let numberOfCellsPerRow = 2
        
        let dimensions = CGFloat(Int(totalwidth) / numberOfCellsPerRow)
        return CGSizeMake(dimensions, dimensions * 1.5)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Makes a network request to get updated data
    // Updates the collectionView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        
        // Configure session so that completion handler is executed on main UI thread
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.collectionView.reloadData()
                    }
                } else {
                    self.errorView.hidden = false
                }
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let movies = movies {
            filteredData = searchText.isEmpty ? movies : movies.filter({(data: NSDictionary) -> Bool in
                return data["title"]!.rangeOfString(searchText, options: .CaseInsensitiveSearch).location != NSNotFound
            })
        }
        
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredData = movies
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UICollectionViewDelegate methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filtered = filteredData {
            return filtered.count
        } else if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }


    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        var movie: NSDictionary
        
        if filteredData != nil {
            movie = filteredData[indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            let imageRequest = NSURLRequest(URL: imageUrl!)
            
            cell.movieImageView.setImageWithURLRequest(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        cell.movieImageView.alpha = 0.0
                        cell.movieImageView.image = image
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            cell.movieImageView.alpha = 1.0
                        })
                    } else {
                        cell.movieImageView.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    cell.movieImageView.setImageWithURL(imageUrl!)
            })
        }
        
        // Use a red color when the user selects the cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.grayColor()
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailsViewController = segue.destinationViewController as! DetailsViewController
        detailsViewController.movie = movie
    }


}
