//
//  ContentView.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import SwiftUI

//struct ContentWrapper:View {
//    @State var viewShower = false
//    var body: some View {
//
//        Button("ToggleView") {
//            viewShower.toggle()
//        }
//
//
//        if viewShower {
//            ContentView()
//        }
//
//    }
//}

struct ContentView: View {
    @State private var showingPopover = false

    //This VM must instiated at the ROOT level of the app, once
    //and ONLY once or you'll continue to spawn tasks.
    @StateObject private var insistant = InsistantFlavorVM()
    //Doing it as a root defined object would be better.
    //@EnvironmentObject var insistant:InsistantFlavorVM

    var body: some View {
        VStack {
            Button("Show & Update While Looking") {
                showingPopover = true
            }
            .popover(isPresented: $showingPopover) {
                //1)Does it say hello goodbye when there is no task.
                //NoAsyncPopOverView()
                //Yes.
                
                //2) Does it say hello goodbye when the task is on the view?
                //SimplestAsyncPopoverView()
                //Yes.
                
                //NOTE: All of these deint when the task finished
                
                //3) Does it say hello goodbye when onAppear / setUp pair?
                //AsyncPopoverSetupFuncView()
                //NO!!!
                
                //4) Does it say hello goodbye when [weak self] is put into the task?
                //AsyncPopoverWeakSetupFuncView()
                //Also no!
                
                //4) What if you do a cancel check inside increment?
                //AsyncPopoverCancelCheckedSetupFuncView()
                //Still no.
                
                //5) How about a tearDown function? (No cancel check, no weak self.)
                //AsyncPopoverTaskKillerView()
                //YES!!!!!
                
                //6) The two objects example, deiniting on dismiss
                CasualFlavorsView()
                
                
                
            }
            //7) Shouls pop back up with every new flavor.
            Button("Drive Background Alerts") {
                insistant.acceptingAlerts = true
                insistant.showMe = true
            }
            .popover(isPresented: $insistant.showMe) {
                InsistantFlavorsView().environmentObject(insistant)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(InsistantFlavorVM())
    }
}
