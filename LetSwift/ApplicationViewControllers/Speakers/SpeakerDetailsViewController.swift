//
//  SpeakerDetailsViewController.swift
//  LetSwift
//
//  Created by Marcin Chojnacki on 15.05.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import UIKit

final class SpeakerDetailsViewController: AppViewController {
    
    override var viewControllerTitleKey: String? {
        return "SPEAKERS_DETAILS_TITLE"
    }
    
    override var shouldHideShadow: Bool {
        return true
    }
    
    @IBOutlet private weak var tableView: AppTableView!
    
    private var viewModel: SpeakerDetailsViewControllerViewModel!
    private lazy var bindableCells: BindableArray<String> = self.allCells.bindable
    
    private let disposeBag = DisposeBag()
    private let sadFaceView = SadFaceView()
    private let allCells = [
        SpeakerHeaderTableViewCell.cellIdentifier,
        SpeakerWebsitesTableViewCell.cellIdentifier,
        SpeakerBioTableViewCell.cellIdentifier
    ]
    
    convenience init(viewModel: SpeakerDetailsViewControllerViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
        tableView.setFooterColor(.paleGrey)
        // TODO: tableView.setHeaderColor(.lightBlueGrey)
        tableView.registerCells(allCells)
        
        reactiveSetup()
    }
    
    private func reactiveSetup() {
        viewModel.speakerObservable.subscribeNext { [weak self] speaker in
            if let shouldShowWebsites = speaker?.hasAnyWebsites, !shouldShowWebsites,
                let index = self?.bindableCells.values.index(of: SpeakerWebsitesTableViewCell.cellIdentifier) {
                self?.bindableCells.remove(at: index)
            } else {
                self?.tableView.reloadData()
            }
        }
        .add(to: disposeBag)
        
        bindableCells.bind(to: tableView.items() ({ [weak self] tableView, index, element in
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.dequeueReusableCell(withIdentifier: element, for: indexPath)
            cell.layoutMargins = UIEdgeInsets.zero
            
            self?.dispatchCellSetup(element: element, cell: cell, index: index)
            
            return cell
        }))
        
        viewModel.tableViewStateObservable.subscribeNext(startsWithInitialValue: true) { [weak self] state in
            switch state {
            case .content:
                self?.tableView.overlayView = nil
            case .error:
                self?.tableView.overlayView = self?.sadFaceView
            case .loading:
                self?.tableView.overlayView = SpinnerView()
            }
        }
        .add(to: disposeBag)
    }
    
    private func dispatchCellSetup(element: String, cell: UITableViewCell, index: Int) {
        switch element {
        case SpeakerHeaderTableViewCell.cellIdentifier:
            setup(headerCell: cell as! SpeakerHeaderTableViewCell)
        case SpeakerBioTableViewCell.cellIdentifier:
            setup(bioCell: cell as! SpeakerBioTableViewCell)
        default: break
        }
    }
    
    private func setup(headerCell cell: SpeakerHeaderTableViewCell) {
        viewModel.speakerObservable.subscribeNext { speaker in
            guard let speaker = speaker else { return }
            
            cell.avatarURL = speaker.avatar?.thumb
            cell.speakerName = speaker.name
            cell.speakerJob = speaker.job
            
            if speaker.hasAnyWebsites {
                cell.removeSeparators()
            }
        }
        .add(to: disposeBag)
    }
    
    private func setup(bioCell cell: SpeakerBioTableViewCell) {
        viewModel.speakerObservable.subscribeNext { speaker in
            cell.speakerName = speaker?.firstName
            cell.speakerBio = speaker?.bio
        }
        .add(to: disposeBag)
    }
}
