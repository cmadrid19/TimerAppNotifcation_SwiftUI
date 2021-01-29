//
//  TimerAppWithBackgroundFetchingApp.swift
//  TimerAppWithBackgroundFetching
//
//  Created by Maxim Macari on 29/1/21.
//

import SwiftUI

@main
struct TimerAppWithBackgroundFetchingApp: App {
    @StateObject var data = TimerData()
    
    //Using scene phase for scene data...
    @Environment(\.scenePhase) var scene
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(data)
        }
        .onChange(of: scene) { (newScene) in
            switch newScene{
            case .active:
                print("app running <foreground> ph (or without focus)")
                //when it enter again -> check the time difference
                if data.time != 0 {
                    let diff = Date().timeIntervalSince(data.leftTime)
                    
                    let currentTime = data.selectedTime - Int(diff)
                    
                    if currentTime >= 0 {
                        withAnimation(.default){
                            data.selectedTime = currentTime
                        }
                    }else{
                        //resetting view
                        data.resetView()
                    }
                }
            case .background:
                print("app running in the BG phase")
                //storing time
                data.leftTime = Date()
            case .inactive:
                print("app inactive or way to the bg phase")
            default:
                ()
            }
            
            
        }
    }
}
