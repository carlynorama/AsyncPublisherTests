//
//  FlavorManager.swift
//  SimpleServiceModel
//
//  Created by carlynorama on 9/8/22.
//
// https://developer.apple.com/documentation/combine/asyncpublisher
// https://www.donnywals.com/comparing-use-cases-for-async-sequences-and-publishers/
// memory issues discussed: https://www.donnywals.com/comparing-lifecycle-management-for-async-sequences-and-publishers/
// https://www.youtube.com/watch?v=ePPm2ftSVqw (How to use AsyncPublisher to convert @Published to Async / Await)
// https://www.hackingwithswift.com/articles/179/capture-lists-in-swift-whats-the-difference-between-weak-strong-and-unowned-references
// https://www.mikeash.com/pyblog/friday-qa-2017-09-22-swift-4-weak-references.html
// https://forums.swift.org/t/explicit-self-not-required-for-task-closures/54364/7

//A quick note on this approach. If you want the viewModel to do a task for the life of the view and then stop, put the Task call IN THE VIEW.

//To catch this typer of thing in XCode 14 (beta build 3+)
//Setting Build Setting > Strict Concurrency Checking

import SwiftUI

struct FlavorsView: View {
    //there is a task creator IN THE INIT of this VM. The tasks will last with the VM or longer. Watch for leaks.
    @StateObject private var viewModel = FlavorVM()
    
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

struct FlavorsView_Previews: PreviewProvider {
    static var previews: some View {
        FlavorsView()
    }
}


struct Flavor:Identifiable {
    let name:String
    let id = UUID()
    let description:String
}

let flavors = [
 Flavor(name: "Vanilla", description: "Yummy"),
 Flavor(name: "Strawberry", description: "Yummy"),
 Flavor(name: "Chocolate", description: "Yummy"),
 Flavor(name: "Butter Pecan", description: "Yummy"),
 Flavor(name: "Mint Chocolate Chip", description: "Yummy"),
]


import Foundation


actor FlavorManager {
    @Published var myFlavors:[Flavor] = []
    @Published var currentFlavor:Flavor = Flavor(name: "Apple Pie", description: "Seasonal Yummy")

    func addData() async {
        for flavor in flavors {
            myFlavors.append(flavor)
            try? await  Task.sleep(nanoseconds: 2_000_000_000)
            currentFlavor = flavor
        }
    }
}

class FlavorVM:ObservableObject {
    @MainActor @Published var flavorsToDisplay: [Flavor] = []
    @MainActor @Published var thisWeeksSpecial:String = ""
    
    let manager = FlavorManager()
    
    var listener:Task<(),Never>?
    
    public func tearDown() {
        listener?.cancel()
    }
    
    init() {
        //spinning up tasks in the init of a ViewModel instead of the
        //view means they will likely persist for longer than the view.
        //inside the listen function set the instance variable instead.
        listen()
    }
    

    //Who owns tasks called here? Who kills them?
    private func listen() {
        //One cannot put one loop after another. Each loop needs
        //it's own task.
        //Use this pattern if you want the task to have to complete.
//        Task { [weak self] in
//            await self?.listenForFlavorList()
//            //No code here will execute because this function never
//            //finishes.
//        }
        
        //Use this pattern if you want it to be cancellable.
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
