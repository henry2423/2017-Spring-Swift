//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by Henry on 07/08/2017.
//  Copyright © 2017 henry. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController {
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    

    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
        
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        print("Start database load")
        container?.performBackgroundTask({ [weak self] context in
            for twitterInfo in tweets {
                //add Tweet
                _ = try? Tweet.findOrCreateTweet(mathing: twitterInfo, in: context) // ignore retrun
            }
            try? context.save()
            print("Done database load")
            
            self?.printDatabaseStatistics()
        })
        
    }
    
    private func printDatabaseStatistics(){
        if let context = container?.viewContext {
            context.perform {
                
                 if Thread.isMainThread {
                 print("on main Thread")
                 } else {
                 print("off main Thread")
                 }
                 
                let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
                if let tweetCount = (try? context.fetch(request))?.count {
                    print("\(tweetCount) tweets")
                }
                
                if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) {
                    print("\(tweeterCount) Twitter users")
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Tweeters Mentioning Search Term" {
            if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.container = container
            }
        }
    }
    
}
