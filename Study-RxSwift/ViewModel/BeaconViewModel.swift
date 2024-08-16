//
//  BeaconViewModel.swift
//  Study-RxSwift
//
//  Created by GENKIFUJIMOTO on 2024/08/16.
//

import RxSwift
import RxCocoa
import CoreLocation

class BeaconViewModel {
    private let beaconManager = BeaconManager()
    private let disposeBag = DisposeBag()
    
    // BeaconデータをViewに提供するためのBehaviorRelay
    let beacons = BehaviorRelay<[String]>(value: [])
    
    init() {
        beaconManager.didRangeBeacons
            .map { beacons in
                beacons.map { beacon in
                    return "Major: \(beacon.major), Minor: \(beacon.minor)"
                }
            }
            .bind(to: beacons)
            .disposed(by: disposeBag)
        
        startRanging()
    }
    
    private func startRanging() {
        beaconManager.startRangingBeacons()
    }
}
