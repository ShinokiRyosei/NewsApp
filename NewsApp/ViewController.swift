//
//  ViewController.swift
//  NewsApp
//
//  Created by ShinokiRyosei on 2017/01/15.
//  Copyright © 2017年 ShinokiRyosei. All rights reserved.
//

import UIKit
import SafariServices

import Alamofire
import SwiftyJSON


// MARK: - ViewController

class ViewController: UIViewController {

    
    // MARK: UIViewController

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.fetchNews { [weak self] news in

            self?.news = news
            self?.tableView.reloadData()
        }
    }
    
    
    // MARK: Fileprivate
    
    fileprivate var news: [News] = []
    
    
    // MARK: Private
    
    @IBOutlet private dynamic weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tableFooterView = UIView()
        }
    }
    
    private func fetchNews(with completion: @escaping ([News]) -> Void) {
        
        //
        Alamofire.request(Config.urlString + Config.apiKey).response { response in
            
            guard let data: Data = response.data else {
                
                return
            }
            let json = JSON(data)
            var newsArray: [News] = []
            json["articles"].array?.forEach({
                
                var news: News = News()
                news.title = $0["title"].stringValue
                news.author = $0["author"].stringValue
                news.description = $0["description"].stringValue
                news.publishedAt = $0["publishedAt"].stringValue
                news.thumbnailURLString = $0["urlToImage"].stringValue
                news.urlString = $0["url"].stringValue
                newsArray.append(news)
            })
            completion(newsArray)
        }
    }
}


// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell: CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as? CustomTableViewCell else {
            
            return UITableViewCell()
        }
        cell.news = news[indexPath.row]
        return cell
    }
}


// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CustomTableViewCell.heightForRow
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let url: URL = URL(string: news[indexPath.row].urlString) else {

            return
        }
        let controllr: SFSafariViewController = SFSafariViewController(url: url)
        self.present(controllr, animated: true, completion: nil)
    }
}
