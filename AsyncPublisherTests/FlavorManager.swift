//
//  FlavorModel.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import Foundation


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
 Flavor(name: "Orange Sherbert", description: "Yummy"),
 Flavor(name: "Rocky Road", description: "Yummy"),
 Flavor(name: "Lemon Sorbet", description: "Yummy"),
 Flavor(name: "Cookie Dough", description: "Yummy"),
 Flavor(name: "Fudge Ripple", description: "Yummy"),
]


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
    
    func slowAddData() async {
        
        for flavor in flavors {
            myFlavors.append(flavor)
            try? await  Task.sleep(nanoseconds: 4_000_000_000)
            currentFlavor = flavor
        }
    }
}


actor FlavorManager2 {
    @Published var myFlavors:[Flavor] = []
    @Published var currentFlavor:Flavor = Flavor(name: "Apple Pie", description: "Seasonal Yummy")
    
    init() {
    }

//    func addData() async {
//
//        for flavor in flavors {
//            Timer.scheduledTimer(withTimeInterval: 4, repeats: false) {  _ in
//                self.myFlavors.append(flavor)
//                self.currentFlavor = flavor
//            }
//        }
//    }

    func addData() async {
        
        for flavor in flavors {
            myFlavors.append(flavor)
            try? await  Task.sleep(nanoseconds: 4_000_000_000)
            currentFlavor = flavor
        }
    }
}
