//
//  BeaconViewController.swift
//  Study-RxSwift
//
//  Created by GENKIFUJIMOTO on 2024/08/16.
//

import UIKit

import RxSwift
import RxCocoa

class BeaconViewController: UIViewController {
    
    private let beaconViewModel = BeaconViewModel()
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableViewBinding()
    }
    
    // TableViewの設定
    private func setupTableViewBinding() {
        
        // TableViewのデータソース設定
        beaconViewModel.beacons
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { index, beacon, cell in
                cell.textLabel?.text = beacon
            }
            .disposed(by: disposeBag)
    }
    
}
