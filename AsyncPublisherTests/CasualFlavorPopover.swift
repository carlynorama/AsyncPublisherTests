//
//  InsistantPopover.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import SwiftUI

struct CasualFlavorsView: View {
    @StateObject private var viewModel = CasualFlavorVM()
    
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
        
        //This is actually the way. if the view model
        //should evaporate with the view. Put the Tasks
        //in the view and in the view only.
        
        //Each must be its own seperate task to run concurently.
        .task {
            await viewModel.start()
        }

        .task {
            await viewModel.listenForFlavorOfTheWeek()
        }
        
        //If the tasks are going to live in the view model,
        //they must be torn down if they are meant
        //to go away with the view.
        //If they are meant to go to completion, it doesn't matter.
        .onDisappear(perform: viewModel.tearDown)
    }
    

}


//Listener architecture to p
class CasualFlavorVM:ObservableObject {
    @MainActor @Published var flavorsToDisplay: [Flavor] = []
    @MainActor @Published var thisWeeksSpecial:String = ""
    
    let manager = FlavorManager()
    
    var listener:Task<(),Never>?
    
    public func tearDown() {
        listener?.cancel()
    }
    
    init() {
        print("hello")
        listen()
    }
    
    deinit {
        print("goodbye")
    }

    //Who owns tasks called here? Who kills them?
    private func listen() {
        listener = Task {
            await listenForFlavorList()
       }
    }
    
    public func listenForFlavorOfTheWeek() async {
        for await value in await manager.$currentFlavor.values {
            await MainActor.run { //[weak self] in
                self.thisWeeksSpecial = "\(value.name): \(value.description)"
            }
        }
    }
    
    public func listenForFlavorList() async {
        for await value in await manager.$myFlavors.values {
            await MainActor.run { //[weak self] in
                self.flavorsToDisplay = value
            }
        }
    }
    
    func start() async {
        await manager.addData()
    }
}


struct CasualFlavorsView_Previews: PreviewProvider {
    static var previews: some View {
        CasualFlavorsView()
    }
}
