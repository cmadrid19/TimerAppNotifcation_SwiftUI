//
//  Home.swift
//  TimerAppWithBackgroundFetching
//
//  Created by Maxim Macari on 29/1/21.
//

import SwiftUI
//sending notification
import UserNotifications

struct Home: View {
    
    @EnvironmentObject var data: TimerData
    
    var body: some View {
        ZStack {
            VStack{
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20){
                        ForEach(1...6, id: \.self){ index in
                            
                            let time = index * 5
                            
                            Text("\(time)")
                                .font(.title)
                                .frame(width: 100, height: 100)
                                //Changing color for selected ones
                                .background(data.time == time ? Color.pink : Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .onTapGesture {
                                    withAnimation{
                                        data.time = time
                                        data.selectedTime = time
                                    }
                                }
                            
                        }
                    }
                    .padding()
                }
                //Setting to center
                .offset(y: 40)
                .opacity(data.buttonAnimation ? 0 : 1)
                
                Spacer()
                
                Spacer()
                
                Button(action: {
                    withAnimation(Animation.easeInOut(duration: 0.65)){
                        data.buttonAnimation.toggle()
                    }
                    //delay animaiton
                    //after button goes down view is moving up...
                    withAnimation(Animation.easeIn.delay(0.6)){
                        data.timerViewOffset = 0
                    }
                    performNotifications()
                }, label: {
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 80, height: 80)
                        
                })
                .padding(.bottom, 35)
                //Disable if not selected
                .disabled(data.time == 0)
                .opacity(data.time == 0 ? 0.6 : 1)
                //moving daon smootly
                .offset(y: data.buttonAnimation ? 300 : 0)
                
                Spacer()
            }
            
            
            Color.pink
                .overlay(
                    Text("\(data.selectedTime)")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                )
                //Decresing height for each count down
                .frame(height: UIScreen.main.bounds.height - data.timerHeightChange)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(.all, edges: .all)
                .offset(y: data.timerViewOffset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.gray
                .opacity(0.1)
                .ignoresSafeArea(.all, edges: .all)
        )
        //timer functionality
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect(), perform: { _ in
            if data.time != 0 && data.selectedTime != 0 && data.buttonAnimation{
                data.selectedTime -= 1
                
                
                //updating height...
                let progressHeight = UIScreen.main.bounds.height / CGFloat(data.time)
                
                let diff = data.time - data.selectedTime
                
                withAnimation(.default){
                    data.timerHeightChange = CGFloat(diff) * progressHeight
                }
                
                if data.selectedTime == 0 {
                    //reseting...
                    data.resetView()
                }
            }
        })
        .onAppear(){
            //permissions
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (response, err) in
                
            }
            
            //setting delegate for in - App notifications...
            UNUserNotificationCenter.current().delegate = data
        }
    }
    
    
    func performNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Notification title"
        content.body = "Timer finished!"
        
        //Triggering at selected time
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(data.time), repeats: false)
        
        let request = UNNotificationRequest(identifier: "TIMER", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (err) in
            if err != nil {
                print(err!.localizedDescription)
            }
        }
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
