//
//  BluetoothService.swift
//  Testing
//
//  Created by Fan Wu on 4/11/22.
//  Copyright © 2022 FW. All rights reserved.
//

import Foundation
import CoreBluetooth

//https://learn.adafruit.com/build-a-bluetooth-app-using-swift-5?view=all
//https://medium.com/@cbartel/ios-scan-and-connect-to-a-ble-peripheral-in-the-background-731f960d520d
//https://uynguyen.github.io/2018/07/23/Best-practice-How-to-deal-with-Bluetooth-Low-Energy-in-background/
//https://uynguyen.github.io/2018/02/21/Play-Central-And-Peripheral-Roles-With-CoreBluetooth/
//https://developer.apple.com/forums/thread/652592
//https://stackoverflow.com/questions/33130124/how-to-trigger-core-bluetooth-state-preservation-and-restoration
//https://thexcodewhisperer.medium.com/core-bluetooh-state-preservation-and-restoration-f107031b32fa
//https://developer.apple.com/documentation/technotes/tn3115-bluetooth-state-restoration-app-relaunch-rules

class BluetoothService: NSObject, ObservableObject {
    struct CBUUIDs{
        //AFD0FFA0-2A9E-41A9-B9DB-115A0E511DE4
        //EE02
        static let BLE_Characteristic_uuid_Tx = CBUUID(string: "EE01") // (Property = Write)
        static let BLE_Characteristic_uuid_Rx = CBUUID(string: "EE02") // (Property = Read/Notify)
    }
    
    @Published var msgForSend = ""
    @Published var receivedMsg = ""
    @Published var secondOfTimer = 1
    private let deviceUUID = "68CE109E-0189-11ED-B939-024200000005"
    private var centralManager: CBCentralManager?
    private var bluefruitPeripheral: CBPeripheral?
    private var txCharacteristic: CBCharacteristic?
    private var rxCharacteristic: CBCharacteristic?
    private var runningTimer: Timer?
    private var cancelledByUser = false
    var myCount = 0
    
    override init() {
        super.init()
        let options = [CBCentralManagerOptionRestoreIdentifierKey: deviceUUID]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        //centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        if centralManager?.isScanning != true {
            if let peripheral = bluefruitPeripheral {
                print("try to connect stored one...")
                centralManager?.connect(peripheral, options: nil)
            }
            else {
                print("startScanning...")
                centralManager?.scanForPeripherals(withServices: [CBUUID(string: deviceUUID)])
            }
        }
    }
    
    func disconnectFromDevice () {
        print("disconnectFromDevice...")
        if let peripheral = bluefruitPeripheral {
            cancelledByUser = true
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    func send(){
        if let bluefruitPeripheral = bluefruitPeripheral,
           let txCharacteristic = txCharacteristic {
            print("is sending: \(msgForSend)")
            bluefruitPeripheral.writeValue(Data(msgForSend.utf8), for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func sendCurrentTime() {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
        print(formatter.string(from: today))
        
        if let bluefruitPeripheral = bluefruitPeripheral,
           let txCharacteristic = txCharacteristic {
            let currentTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
            bluefruitPeripheral.writeValue(Data(formatter.string(from: currentTime).utf8), for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func read() {
        if let bluefruitPeripheral = bluefruitPeripheral,
           let rxCharacteristic = rxCharacteristic {
            bluefruitPeripheral.readValue(for: rxCharacteristic)
        }
    }
    
    func stopTimer() {
        runningTimer?.invalidate()
        runningTimer = nil
    }
    
    func startTimer(_ task: @escaping () -> ()) {
        stopTimer()
        task()
        runningTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(secondOfTimer), repeats: true) { _ in
            task()
        }
    }
    
    func increaseSecondOfTimer(_ task: @escaping () -> ()) {
        secondOfTimer += 1
        startTimer(task)
    }
    
    func decreaseSecondOfTimer(_ task: @escaping () -> ()) {
        if secondOfTimer > 1 {
            secondOfTimer -= 1
            startTimer(task)
        }
    }
}

extension BluetoothService: CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate {
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("willRestoreState...")
        NotificationService.shared.sendNotification("willRestoreState", subtitle: "", inSecond: 1)
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            peripherals.forEach { (awakedPeripheral) in
                print("\(Date.now). - Awaked peripheral \(awakedPeripheral)")
                bluefruitPeripheral = awakedPeripheral
                bluefruitPeripheral?.delegate = self
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            startScanning()
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Peripheral Discovered: \(peripheral) Advertisement Data : \(advertisementData)")
        bluefruitPeripheral = peripheral
        bluefruitPeripheral?.delegate = self
        centralManager?.stopScan()
        if let peripheral = bluefruitPeripheral {
            centralManager?.connect(peripheral, options: nil)
            //centralManager?.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnConnectionKey:true, CBConnectPeripheralOptionNotifyOnDisconnectionKey: true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect...")
        bluefruitPeripheral?.discoverServices(nil) //[CBUUID(string: "AAAA")] or nil
        
//        NotificationService.shared.sendNotification("didConnect", subtitle: "", inSecond: 1)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
//            self?.disconnectFromDevice()
//        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral...")
        NotificationService.shared.sendNotification("didDisconnectPeripheral", subtitle: "", inSecond: 1)
        if cancelledByUser {
            cancelledByUser = false
        } else {
            print("will connect in 2 second...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                if let peripheral = self?.bluefruitPeripheral {
                    self?.centralManager?.connect(peripheral, options: nil)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else { return }
        //We need to discover the all characteristic
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        //print("Discovered Services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("didModifyServices: \(invalidatedServices)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        //print("Found \(characteristics.count) characteristics.")
        
        for characteristic in characteristics {
            print("characteristic: \(characteristic.uuid.uuidString)")
            
            if characteristic.uuid.uuidString.contains("A001")  {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                    print("read live data A001")
                    self?.rxCharacteristic = characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral Is Powered On.")
        case .unsupported:
            print("Peripheral Is Unsupported.")
        case .unauthorized:
            print("Peripheral Is Unauthorized.")
        case .unknown:
            print("Peripheral Unknown")
        case .resetting:
            print("Peripheral Resetting")
        case .poweredOff:
            print("Peripheral Is Powered Off.")
        @unknown default:
            print("Error")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let characteristicValue = rxCharacteristic?.value {
            let newString = String(decoding: characteristicValue, as: UTF8.self)
            if newString != "" {
                print("myCount: \(myCount)")
                myCount += 1
                print("newString: \(newString)***\(myCount)")
            }
            let processedMsg = interpretMsg(newString)
            receivedMsg = "\(processedMsg) \nCount: \(myCount)"
            print("receivedMsg: \(receivedMsg)")
//            if myCount % 1 == 0 {
//                NotificationService.shared.sendNotification("didUpdateValueFor", subtitle: receivedMsg, inSecond: 1)
//            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueFor characteristic 1111")
    }
    
    func interpretMsg(_ msg: String) -> String {
        var result = ""
        let msgArray = msg.components(separatedBy: ",")
        for (index, content) in msgArray.enumerated() {
            if index == 0 {
                result = "Frequency: \(content)Hz"
            }
            if index == 1 {
                result += "\nVrms: \(content)V"
            }
            if index == 2 {
                result += "\nIrms: \(content)A"
            }
            if index == 3 {
                result += "\nPower (R): \(content)W"
            }
            if index == 4 {
                result += "\nPower (A): \(content)W"
            }
            if index == 5 {
                result += "\nPower Factor: \(content)"
            }
        }
        return result
    }
}
