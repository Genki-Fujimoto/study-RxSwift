//
//  TopViewController.swift
//  Study-RxSwift
//
//  Created by GENKIFUJIMOTO on 2024/08/16.
//

import UIKit
import RxSwift
import RxCocoa

/// .rxはイベントや状態のストリーム（Observable）を生成
/// .bindはそのストリームを他のUIコンポーネントにバインドして更新するために使用
/// .subscribeは、Observableのデータストリームに対してリスナーを設定し、イベントが発生したときに何かしらの処理を実行
/// .withLatestFrom 指定されたObservable（ここではtodoItems）の最新の値を取得
/// BehaviorRelay: 最新の値を保持し、購読者に対してその最新の値を提供するRelayの一種
/// bindメソッドでバインドできるのは通常、AnyObserverやBinder
/// デリゲートを使用しないで実装が可能
///
/// 
///
/*
 Observable.of
 BehaviorRelay
 主な違い
 データの変更:

 Observable.ofはデータのストリームを提供し、発行後はデータを変更できません。
 BehaviorRelayはデータの状態を保持し、変更可能です。
 データの発行:

 Observable.ofは一度だけデータを発行し、完了します。
 BehaviorRelayはデータが更新されるたびに新しい値を発行し続けます。
 状態の保持:

 Observable.ofは状態を保持しません。
 BehaviorRelayは最新の状態を常に保持し、リスナーに最新の値を提供します。
 使用例
 Observable.of: 一度限りのデータ発行が必要な場合、例えば初期データの提供など。
 BehaviorRelay: データの状態を管理し、UIコンポーネントと連携させる場合、例えばリストのデータソースやユーザー入力の状態など。
 用途に応じて、ObservableまたはBehaviorRelayを選択してください。
 
 
 */


class TopViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var disposeBag = DisposeBag()
    private var stydyItems = BehaviorRelay<[String]>(value: ["TODO リスト","ビーコン取得","Pixcels API"])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 初期設定
        self.setupTableViewBinding()
        self.setupNavigationBar()
        
    }
    
    // navigationBarの設定
    private func setupNavigationBar(){
        navigationItem.title = "RsSwift 学習リスト"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
                title:  "back",
                style:  .plain,
                target: nil,
                action: nil
            )
    }

    // TableViewの設定
    private func setupTableViewBinding() {
        
        // テーブルビューのデリゲートやデータソースをRxCocoaでバインド
        stydyItems
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { row, item, cell in
                cell.textLabel?.text = item
            }
            .disposed(by: disposeBag)
        
        // セルがタップされたときの処理
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                nextViewController(indexPath: indexPath.row)
            })
            .disposed(by: disposeBag)
    }
    
    // 画面遷移
    
    private func nextViewController(indexPath:Int){
        
        let identifier: String
        
        switch indexPath {
        case 0:
            identifier = "TodoListViewController"
        case 1:
            identifier = "BeaconViewController"
        case 2:
            identifier = "PexelsApiViewController"
        default:
            return // その他のケースでは何もしない
        }
        
        guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: identifier) else {
            return
        }
        
        // 画面遷移
        if let navigationController = self.navigationController {
            navigationController.pushViewController(nextViewController, animated: true)
        } else {
            self.present(nextViewController, animated: true, completion: nil)
        }
        
    }
}
