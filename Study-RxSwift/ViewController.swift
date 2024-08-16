//
//  ViewController.swift
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
/// デリゲートを使用しないで実装が可能

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var todoTextField: UITextField!
    
    private var disposeBag = DisposeBag()
    private var isKeyboardVisible = false
    private var tapGesture: UITapGestureRecognizer?
    
    // Todoリストを管理するBehaviorRelay
    // BehaviorRelay<[String]>で、RxSwiftのBehaviorRelayを使用して配列の状態を管理
    // BehaviorRelayは、配列のデータが変更されたときにその変更を購読者（この場合はUITableView）に通知
    private var todoItems = BehaviorRelay<[String]>(value: [])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初期設定
        self.setupTableViewBinding()
        self.setupAddButton()
        self.setupTodoTextfield()
    }
    
    // TableViewの設定
    private func setupTableViewBinding() {
        
        // テーブルビューのデリゲートやデータソースをRxCocoaでバインド
        todoItems
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, item, cell in
                cell.textLabel?.text = item
            }
            .disposed(by: disposeBag)
        
        // セルがタップされたときの処理
        tableView.rx.itemSelected
            .withLatestFrom(todoItems) { indexPath, items in
                
                // セルを取得しチェックマーク処理
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.accessoryType = (cell?.accessoryType == .checkmark) ? .none : .checkmark
                self.tableView.deselectRow(at: indexPath, animated: true)
                
                return items[indexPath.row] // タップされたセルのデータを取得
            }
            .subscribe(onNext: { [weak self] selectedItem in
                guard let self = self else { return }
                
                // 画面遷移
                guard let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
                    return
                }
                detailViewController.item = selectedItem
                
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(detailViewController, animated: true)
                } else {
                    self.present(detailViewController, animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
        
        // セルの削除処理
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                
                var items = self.todoItems.value
                items.remove(at: indexPath.row)
                self.todoItems.accept(items)
            })
            .disposed(by: disposeBag)
    }
    
    // Addボタンの設定
    private func setupAddButton() {
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self, let text = self.todoTextField.text, !text.isEmpty else { return }
                var items = self.todoItems.value
                items.append(text)
                self.todoItems.accept(items)
                self.todoTextField.text = ""  // 入力フィールドをクリア
            })
            .disposed(by: disposeBag)
    }
    
    // テキストフィールドの設定
    private func setupTodoTextfield() {
        
        // キーボードの表示・非表示を監視する
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.isKeyboardVisible = true
                self?.setupTapGesture()
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] _ in
                self?.isKeyboardVisible = false
                self?.removeTapGesture()
            })
            .disposed(by: disposeBag)
        
        
        // テキスト変更を監視
        todoTextField.rx.text
            .orEmpty
            .subscribe(onNext: { text in
                
            })
            .disposed(by: disposeBag)
        
        
        // テキストフィールドの編集終了でキーボードを閉じる
        todoTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                
                self?.todoTextField.resignFirstResponder() // 閉じる
                
                guard let self = self, let text = self.todoTextField.text, !text.isEmpty else { return }
                var items = self.todoItems.value
                items.append(text)
                self.todoItems.accept(items)
                
                self.todoTextField.text = ""  // 入力フィールドをクリア
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTapGesture() {
        guard tapGesture == nil else { return }
        tapGesture = UITapGestureRecognizer()
        tapGesture?.rx.event
            .subscribe(onNext: { [weak self] _ in
                // キーボードが表示されている場合にのみキーボードを閉じる
                if self?.isKeyboardVisible == true {
                    self?.view.endEditing(true)
                }
            })
            .disposed(by: disposeBag)
        if let tapGesture = tapGesture {
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    private func removeTapGesture() {
        if let tapGesture = tapGesture {
            view.removeGestureRecognizer(tapGesture)
            self.tapGesture = nil
        }
    }
    
}
