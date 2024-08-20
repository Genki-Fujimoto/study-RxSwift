//
//  PexelesApiViewModel.swift
//  Study-RxSwift
//
//  Created by GENKIFUJIMOTO on 2024/08/16.
//

import Foundation
import Alamofire
import RxSwift

class PexelesApiViewModel {
    
/* searchWordに値が渡される:
    
    外部のコードがsearchWordに対して新しい検索ワードを渡します（onNext("検索ワード")）。
    searchWordからsearchWordSubjectに値が渡される:

    searchWordSubject.asObserver()を通じて、その値はsearchWordSubjectに渡されます。
    searchWordSubjectがイベントを発行:

    searchWordSubjectは、新しい検索ワードを受け取ると、内部でその値を購読しているsubscribeが実行され、searchEvents(keyword:)が呼び出されます。
*/


    private let disposeBag = DisposeBag()
    
    // 検索ワードを受け取るための Observer
    private let searchWordSubject = PublishSubject<String>()
    
    // データを保持するための PublishSubject
    private let apiSubject = PublishSubject<Api?>()
    
    // 外部からアクセス可能な Observable
    var apiObservable: Observable<Api?> {
        return apiSubject.asObservable()
    }
    
    // 外部からアクセス可能な Observable
    var searchWord: AnyObserver<String> {
            return searchWordSubject.asObserver()
    }
    
    /*
    searchWordSubjectは、init()内でsubscribeされています。
    これにより、searchWordSubjectが新しい検索ワードを受け取るたびに、そのワードに基づいてsearchEvents(keyword:)が呼び出されます
    */
    
    init() {
        // searchWordSubjectが発行するイベントを受け取って(subscribe)処理する
        searchWordSubject
            .distinctUntilChanged() // 同じワードの連続発行を無視
            .subscribe(onNext: { [weak self] keyword in
                self?.searchEvents(keyword: keyword)
            })
            .disposed(by: disposeBag)
    }
    
    // イベントを検索するメソッド
        func searchEvents(keyword: String) {
            
            // APIキー
            let headers: HTTPHeaders = [
                "Authorization": "563492ad6f91700001000001bf70f8ac0fec4a169e874cb63b6d10d0",
            ]
            
            // リクエスト先URL
            let urlString = "https://api.pexels.com/v1/search?query=\(keyword)&locale=ja-JP&per_page=10"
            
            // エンコーディング
            let encodeUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            
            // APIリクエスト
            AF.request(encodeUrlString, method: .get, headers: headers).response { response in
                
                switch response.result {
                case .success:
                    if let data = response.data {
                        let decoder = JSONDecoder()
                        if let result = try? decoder.decode(Api.self, from: data) {
                            print(result)
                            // データを発行する
                            self.apiSubject.onNext(result)
                        }
                    }
                case .failure(let error):
                    // エラーを発行する
                    self.apiSubject.onError(error)
                }
            }
        }
    
    
}
