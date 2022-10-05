//
//  Testing2022App.swift
//  Shared
//
//  Created by Fan Wu on 4/12/22.
//

import SwiftUI

@main
struct Testing2022App: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var bluetoothService = BluetoothService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetoothService)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                //BackgroundTasksService.shared.submitBackgroundTasks()
                break
            case .active:
//                BackgroundTasksService.shared.bgTask = {
//                    bluetoothService.runTimer()
//                }
//                bluetoothService.update()
                break
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}
