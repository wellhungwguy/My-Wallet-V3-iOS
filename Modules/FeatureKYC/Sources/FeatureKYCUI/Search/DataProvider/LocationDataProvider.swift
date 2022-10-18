// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

class LocationDataProvider: NSObject {

    // MARK: Public Properties

    var locationResult: LocationSearchResult {
        didSet { update() }
    }

    // MARK: Private Properties

    fileprivate weak var tableView: UITableView?

    // MARK: Lifecycle

    init(with table: UITableView) {
        tableView = table
        locationResult = .empty
        tableView?.estimatedRowHeight = 80
        super.init()

        tableView?.dataSource = self
        registerCells()
        tableView?.reloadData()
    }

    // MARK: Private Functions

    fileprivate func registerCells() {
        guard let tableView else { return }
        tableView.registerNibCell(LocationSuggestionCell.self, in: .module)
    }

    fileprivate func update() {
        guard let tableView else { return }
        tableView.reloadData()

        switch locationResult.state {
        case .empty:
            tableView.alpha = 0.0
        case .error:
            // TODO: Error handling
            break
        case .loading:
            break
        case .success:
            tableView.alpha = 1.0
        }
    }
}

extension LocationDataProvider: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locationResult.suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard locationResult.suggestions.isEmpty == false else { return UITableViewCell() }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: LocationSuggestionCell.identifier
        ) as? LocationSuggestionCell else { return UITableViewCell() }

        cell.configure(with: locationResult.suggestions[indexPath.row])
        return cell
    }
}
