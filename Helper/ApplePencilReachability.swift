//
//  iPencel.swift
//  Hospital
//
//  Created by Alex on 8/3/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import CoreBluetooth



class ApplePencilReachability: NSObject, CBCentralManagerDelegate {
    
    private let centralManager = CBCentralManager()
    var pencilAvailabilityDidChangeClosure: ((_ isAvailable: Bool) -> Void)?
    
    var timer: Timer? {
        didSet {
            if oldValue !== timer { oldValue?.invalidate() }
        }
    }
    
    var isPencilAvailable = false {
        didSet {
            guard oldValue != isPencilAvailable else { return }
            pencilAvailabilityDidChangeClosure?(isPencilAvailable)
        }
    }
    
    override init() {
        super.init()
        centralManager.delegate = self
        centralManagerDidUpdateState(centralManager)        // can be powered-on already?
    }
    
    deinit { timer?.invalidate() }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
                [weak self] timer in                // break retain-cycle
                self?.checkAvailability()
                if self == nil { timer.invalidate() }
            }
        } else {
            timer = nil
            isPencilAvailable = false
        }
    }
    
    private func checkAvailability() {
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: "180A")])
        _ = isPencilAvailable
        isPencilAvailable = peripherals.contains(where: { $0.name == "Apple Pencil" })
        if isPencilAvailable {
            timer = nil // only if you want to stop once detected
        }
    }
    
}


