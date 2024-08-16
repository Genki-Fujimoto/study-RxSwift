//
//  PexelsApiViewController.swift
//  Study-RxSwift
//
//  Created by GENKIFUJIMOTO on 2024/08/16.
//

import UIKit
import RxSwift
import RxCocoa

class PexelsApiViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let pexelesApiViewModel = PexelesApiViewModel()
    private var todoItems = BehaviorRelay<[ListItem]>(value: [])
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableViewBinding()
    }
    
    // TableViewの設定
    private func setupTableViewBinding() {
        
        // searchBarのテキストが変更されたときにsearchWordStreamにバインド
        searchBar.rx.text.orEmpty
            .bind(to: pexelesApiViewModel.searchWord)
            .disposed(by: disposeBag)
        
        
        pexelesApiViewModel.apiObservable
            .compactMap { $0?.photos } // Apiオブジェクトから写真リストを抽出
            .bind(to: todoItems) // todoItemsにデータをセット
            .disposed(by: disposeBag)
        
        // テーブルビューのデリゲートやデータソースをRxCocoaでバインド
        todoItems
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, item, cell in
                cell.textLabel?.text = item.photographer
            }
            .disposed(by: disposeBag)
        
//        // セルがタップされたときの処理
//        tableView.rx.itemSelected
//            .withLatestFrom(todoItems) { indexPath, items in
//                
//                // セルを取得しチェックマーク処理
//                let cell = self.tableView.cellForRow(at: indexPath)
//                cell?.accessoryType = (cell?.accessoryType == .checkmark) ? .none : .checkmark
//                self.tableView.deselectRow(at: indexPath, animated: true)
//                
//                return items[indexPath.row] // タップされたセルのデータを取得
//            }
//            .subscribe(onNext: { [weak self] selectedItem in
//                guard let self = self else { return }
//                
//                let detailViewController = DetailViewController()
//                detailViewController.item = selectedItem // データを設定
//                
//                // 画面遷移
//                self.present(detailViewController, animated: true, completion: nil)
//                
//            })
//            .disposed(by: disposeBag)
        
    }

}
