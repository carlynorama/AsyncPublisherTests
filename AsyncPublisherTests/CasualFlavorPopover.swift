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
        //Each must be its own seperate task to run concurently.
        .task {
            await viewModel.start()
        }
        
        .task {
            //should be cleaned up and not leak.
            await viewModel.listenForFlavorOfTheWeek()
        }
        .onDisappear(perform: viewModel.tearDown)
    }
    

}

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
