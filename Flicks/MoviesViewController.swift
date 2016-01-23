//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Lainie Wright on 1/10/16.
//  Copyright © 2016 lainiewright. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    
    var filteredData: [NSDictionary]!
    var searchActive: Bool! = false

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        filteredData = movies
        
        // Flow Layout properties
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)

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
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.collectionView.reloadData()
                    }
                }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredData = searchText.isEmpty ? movies : movies!.filter({(data: NSDictionary) -> Bool in
            return data["title"]!.rangeOfString(searchText, options: .CaseInsensitiveSearch).location != NSNotFound
        })
        
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout methods
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
////        let totalwidth = collectionView.bounds.size.width;
////        let numberOfCellsPerRow = 2
////        let dimensions_width = CGFloat(Int(totalwidth) / numberOfCellsPerRow)
////        return CGSizeMake(dimensions_width, dimensions)
//    }
    
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
        
        print(indexPath.row)
        
        if filteredData != nil {
            movie = filteredData[indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        cell.movieImageView.setImageWithURL(imageUrl!)
        
        return cell
    }

}
