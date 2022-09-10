//
//  InsistantPopover.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import Foundation
import SwiftUI


struct InsistantFlavorsView: View {
    //there is a task creator IN THE INIT of this VM. The tasks will last with the VM or longer. Watch for leaks.
    @EnvironmentObject private var viewModel:InsistantFlavorVM
    

    var body: some View {
        VStack {
            Text(viewModel.thisWeeksSpecial)
            ScrollView {
                VStack {
                    ForEach(viewModel.flavorsToDisplay) {
                        Text($0.name)
                    }
                }
            }
        }
        //Each must be its own seperate task to run concurently.

        .task {
            //This runs it's defer on view dismiss.
            await viewModel.listenForFlavorOfTheWeek()
        }
    }


}

struct InsistantFlavorsView_Previews: PreviewProvider {
    static var previews: some View {
        InsistantFlavorsView().environmentObject(InsistantFlavorVM())
    }
}


class InsistantFlavorVM:ObservableObject {
    @MainActor @Published var flavorsToDisplay: [Flavor] = []
    @MainActor @Published var thisWeeksSpecial:String = ""

    //I believe this will keep this instance alive?
    // can this be weak? it needs to also have a task killer?
    let manager = FlavorManager()
    
    @MainActor @Published var showMe:Bool = false
    @MainActor @Published var acceptingAlerts = false

    init() {
        print("background hello")
        //spinning up tasks in the init of a ViewModel instead of the
        //view means they will likely persist for longer than the view.
        //inside the listen function set the instance variable instead.
        
        listen()
    }
    
    deinit {
        print("never say goodbye...")
    }
    
    


    //Who owns tasks called here? Who kills them?
    private func listen() {
        //One cannot put one loop after another. Each loop needs
        //it's own task.
        //Use this pattern if you want the task to have to complete.
        //They appear to run even when App is in the background.
        
        //Note: Assigning a task to a variable does not "save it for later"
        //this task starts running now. 
        let dataLoading = Task { await manager.slowAddData() }
        
        Task { [weak self] in
            //This DOES NOT run its defer on view dismiss.
            await self?.listenForFlavorList()
            //No code here will execute because this function never
            //finishes.
        }
    }
    
    public func listenForFlavorOfTheWeek() async {
        defer { print("IFVM, lfFtW:How about defer?") }
        
        for await value in await manager.$currentFlavor.values {
            await MainActor.run { //[weak self] in
                self.thisWeeksSpecial = "\(value.name): \(value.description)"
            }
        }
    }

    public func listenForFlavorList() async {
        defer { print("IFVM, lfFL:How about defer?") }
        
        for await value in await manager.$myFlavors.values {
            await MainActor.run { //[weak self] in
                if self.acceptingAlerts {
                    self.showMe = true
                }
                self.flavorsToDisplay = value
            }
        }
    }
    
    
}


