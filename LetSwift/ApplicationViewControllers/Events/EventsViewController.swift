//
//  EventsViewController.swift
//  LetSwift
//
//  Created by Marcin Chojnacki, Kinga Wilczek on 21.04.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import UIKit

final class EventsViewController: AppViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate enum Constants {
        static let viewCells = [
            "StaticImageCell",
            "AttendButtonsRowCell",
            "EventSummaryCell",
            "EventLocationCell",
            "EventTimeCell"
        ]
    }
    
    private var viewModel: EventsViewControllerViewModel!

    convenience init(viewModel: EventsViewControllerViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewControllerTitleKey() -> String? {
        return "EVENTS_TITLE"
    }

    override func shouldShowUserIcon() -> Bool {
        return true
    }

    override func shouldHideShadow() -> Bool {
        return true
    }

    private func setup() {
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
        tableView.tableFooterView = UIView()
        
        Constants.viewCells.forEach { cell in
            tableView.register(UINib(nibName: cell, bundle: nil), forCellReuseIdentifier: cell)
        }
    }
}

extension EventsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.viewCells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.viewCells[indexPath.row], for: indexPath)

        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, cell.bounds.width)
        }
        
        return cell
    }
}
