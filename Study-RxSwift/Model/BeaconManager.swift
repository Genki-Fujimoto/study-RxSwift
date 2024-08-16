//
//  BeaconManager.swift
//  Study-RxSwift
//
//  Created by GENKIFUJIMOTO on 2024/08/16.
//

import CoreLocation
import RxSwift
import RxCocoa

class BeaconManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
   /*
    PublishSubjectの概要
    PublishSubjectは、RxSwiftのSubjectの一種で、次の特徴があります:
    発行（Publish）: 新しく購読を始めた際に、PublishSubjectはそれまで発行されたイベントを一切提供しません。購読開始以降のイベントのみを通知します。
    イベントの通知: イベント（この場合は[CLBeacon]の配列）を購読者に通知するためのメカニズムを提供します。
    可変（Mutable）: PublishSubjectは、外部からイベントを発行（onNext）できるため、リアルタイムのデータストリームに適しています。
  */
    let didRangeBeacons = PublishSubject<[CLBeacon]>()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startRangingBeacons() {
        let beaconRegion = CLBeaconRegion(uuid: UUID(uuidString: "e8c65602-6d9c-44ef-9734-b2d3ef1cd961")!, identifier: "tgr")
        locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        
        // onNextメソッドを使って、[CLBeacon]の配列を購読者に通
        didRangeBeacons.onNext(beacons)
    }
}
