//
//  PexelsApiViewController.swift
//  Study-RxSwift
//
//  Created by GENKIFUJIMOTO on 2024/08/16.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class PexelsApiViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let pexelesApiViewModel = PexelesApiViewModel()
    private var photoLists = BehaviorRelay<[ListItem]>(value: [])
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }
    
    
    private func setupBindings() {
        
        // searchBarのテキスト変更のバインディング
        searchBar.rx.text.orEmpty
            .bind(to: pexelesApiViewModel.searchWord)
            .disposed(by: disposeBag)
        
        // APIから取得した写真リストのバインディング
        pexelesApiViewModel.apiObservable
            .compactMap { $0?.photos } // Apiオブジェクトから写真リストを抽出
            .bind(to: photoLists) // todoItemsにデータをセット
            .disposed(by: disposeBag)
        
        // テーブルビューのデリゲートやデータソースをRxCocoaでバインド
        photoLists
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, item, cell in
                
                guard let contentsImageView = cell.contentView.viewWithTag(1) as? UIImageView else { return }
                guard let artName = cell.contentView.viewWithTag(2) as? UILabel else { return }
                guard let photoGrapher = cell.contentView.viewWithTag(3) as? UILabel else { return }
                
                if let setImageUrl = item.src?.tiny, let photographer = item.photographer, let artNameText = item.alt {
                    contentsImageView.sd_setImage(with: URL(string: setImageUrl), placeholderImage: nil, options: .continueInBackground, completed: nil)
                    photoGrapher.text = "撮影者: " + photographer
                    artName.text = "【作品名】\n" + artNameText
                }
            }
            .disposed(by: disposeBag)
        
        // UISearchBarのデリゲートを設定
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] in
                // キーボードを閉じる
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        // セルがタップされたときの処理
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                
                // タップされたアイテムを取得
                guard let  selectedItemPhotoLargeUrl = self.photoLists.value[indexPath.row].src?.large else { return }
                
                // ImageDetailViewController に画像を渡す
                let imageDetailViewController = ImageDetailViewController()
                imageDetailViewController.photoLargeUrl = selectedItemPhotoLargeUrl
                
                // 画面遷移
                self.present(imageDetailViewController, animated: true, completion: nil)
                
            })
            .disposed(by: disposeBag)
    }
}


class ImageDetailViewController: UIViewController {

    private let imageView = UIImageView()
    var photoLargeUrl = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        imageView.sd_setImage(with: URL(string:photoLargeUrl))
    }
    
    private func setupImageView() {
        // 画像ビューの設定
        imageView.contentMode = .scaleAspectFill // 画像をアスペクト比を維持して画面いっぱいに表示
        imageView.clipsToBounds = true // 画像がビューの境界を超えないようにする
        
        // 画像ビューをビューに追加
        view.addSubview(imageView)
        
        // Auto Layoutの設定
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
