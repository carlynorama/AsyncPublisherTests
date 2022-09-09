//
//  ContentView.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import SwiftUI

struct ContentView: View {
    @State private var showingPopover = false

    var body: some View {
        Button("Show Menu") {
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
            
            //4)Does it say hello goodbye when [weak self] is put into the task?
            //AsyncPopoverWeakSetupFuncView()
            //Also no!
            
            //4)What if you do a cancel check inside increment?
            //AsyncPopoverCancelCheckedSetupFuncView()
            //Still no.
            
            //5)How about a tearDown function?
            AsyncPopoverModelKillerFuncView()
            //YES!!!!!
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
