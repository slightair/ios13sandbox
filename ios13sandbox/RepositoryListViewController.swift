import UIKit
import APIKit

class RepositoryListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = GitHubAPI.SearchRepositoriesRequest(query: "swift")
        Session.send(request) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
