//
//  NoAsyncPopOverView.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import SwiftUI

class minimalViewModel:ObservableObject {
    @Published var counter:Int = 0
    
    init() {
        print("hello")
    }
    
    deinit {
        print("goodbye")
    }
}

struct NoAsyncPopOverView: View {
    @StateObject var viewModel = minimalViewModel()
    
    var body: some View {
        Text("\(viewModel.counter)")
        Stepper("counter", value: $viewModel.counter)
    }
}

struct NoAsyncPopOverView_Previews: PreviewProvider {
    static var previews: some View {
        NoAsyncPopOverView()
    }
}
