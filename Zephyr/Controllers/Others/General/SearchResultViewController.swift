//
//  SearchResultViewController.swift
//  Zephyr
//
//  Created by Eclipse on 18/06/24.
//

import UIKit
protocol SearchResultViewControllerDelegate{
    func didSelectUser(userName: String)
}
class SearchResultViewController: UIViewController {
    deinit{
        print("No memory leaks!!")
    }
    var query: String? {
            didSet {
                performSearch()
            }
        }
    var queryResult: [UserModel] = []
    var searches: [String:[UserModel]] = [:]
    var userProfileSegueUserName: String?
    var delegate: SearchResultViewControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: Constants.SearchResult.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.SearchResult.cellNibName)
        tableView.dataSource = self
        tableView.delegate = self
        performSearch()
    }
    func performSearch() {
        guard let query = query, !query.isEmpty else {
            queryResult = []
            tableView.reloadData()
            return
        }
        if searches[query] != nil{
            self.queryResult = searches[query] ?? []
            self.tableView.reloadData()
            return
        }
        DatabaseManager.shared.fetchUsers(matching: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self?.queryResult = users
                    self?.searches[query] = users
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching user data: \(error.localizedDescription)")
                    self?.queryResult = []
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchResultViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        queryResult.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.SearchResult.cellNibName, for: indexPath) as! SearchResultTableViewCell
        let user = queryResult[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchResultViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userName = queryResult[indexPath.row].userName
        delegate?.didSelectUser(userName: userName)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
