//
//  ContentView.swift
//  Shared
//
//  Created by Fan Wu on 4/12/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    
    var body: some View {
        VStack {
            Button("Send Current deddddddd2d") {
                bluetoothService.sendCurrentTime()
            }
            .padding()
            .border(Color.blue, width: 1)
            
            HStack {
                TextField("", text: $bluetoothService.msgForSend)
                    .padding()
                    .border(Color.black, width: 1)
                    .multilineTextAlignment(.center)
                
                Button("Sendeeeeeeeee") {
                    bluetoothService.send()
                }
                .padding()
                .border(Color.blue, width: 1)
            }
            
            HStack {
                Button("Read:") {
                    bluetoothService.read()
                }
                .padding()
                .border(Color.blue, width: 1)
                
                Text("\(bluetoothService.receivedMsg)")
                    .padding()
                
                Spacer()
            }
            
            HStack {
                
                Button("Read Every \(bluetoothService.secondOfTimer)s") {
                    bluetoothService.startTimer {
                        bluetoothService.read()
                    }
                }
                .padding()
                .border(Color.blue, width: 1)
                
                Spacer()
                
                Button("+") {
                    bluetoothService.increaseSecondOfTimer {
                        bluetoothService.read()
                    }
                }
                .padding()
                .border(Color.blue, width: 1)
                
                Spacer()
                
                Button("-") {
                    bluetoothService.decreaseSecondOfTimer {
                        bluetoothService.read()
                    }
                }
                .padding()
                .border(Color.blue, width: 1)
                
                Spacer()
            }
            
            Button("Stop Reading") {
                bluetoothService.stopTimer()
            }
            .padding()
            .border(Color.blue, width: 1)
            
            HStack {
                Button("Scan or Connect") {
                    bluetoothService.startScanning()
                }
                .padding()
                .border(Color.blue, width: 1)
                
                Spacer()
                
                Button("Cancel Connection") {
                    bluetoothService.disconnectFromDevice()
                }
                .padding()
                .border(Color.blue, width: 1)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BluetoothService())
    }
}
