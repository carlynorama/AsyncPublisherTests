//
//  SimplestAsyncPopoverView.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import SwiftUI

class asyncViewModel:ObservableObject {
    @Published var counter:Int = 0
    
    init() {
        print("hello")
    }
    
    deinit {
        print("goodbye")
    }
    
    private var counterTask: Task<(), Never>?
    
    public func increment() async {
        while counter < 8 {
           
            await MainActor.run {
                counter += 1
            }
            try? await  Task.sleep(nanoseconds: 2_000_000_000)
        }
    }
    
    public func cancelCeckedIncrement() async {
        while counter < 8 {
            
            await MainActor.run {
                counter += 1
            }
            try? await  Task.sleep(nanoseconds: 2_000_000_000)
            if Task.isCancelled { break }
        }
    }
    
    
    public func setUp()  {
        Task {
            await increment()
        }
    }
    
    public func weakSetUp()  {
        Task { [weak self] in
            await self?.increment()
        }
    }
    
    
    public func cancelCheckedWeakSetUp()  {
        Task { [weak self] in
            await self?.cancelCeckedIncrement()
        }
    }
    
    
    
    public func instanceTaskSetUp() {
        counterTask = Task {
           await increment()
        }
    }
    
    public func tearDown() {
        counterTask?.cancel()
    }
    

}

struct AsyncPopoverTaskKillerView: View {
    @StateObject var viewModel = asyncViewModel()

    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.onDisappear(perform: viewModel.tearDown)
        .onAppear(perform: viewModel.instanceTaskSetUp)
    }
}

struct AsyncPopoverCancelCheckedSetupFuncView: View {
    @StateObject var viewModel = asyncViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.onAppear(perform: viewModel.cancelCheckedWeakSetUp)
    }
}

struct AsyncPopoverWeakSetupFuncView: View {
    @StateObject var viewModel = asyncViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.onAppear(perform: viewModel.weakSetUp)
    }
}

struct AsyncPopoverSetupFuncView: View {
    @StateObject var viewModel = asyncViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.onAppear(perform: viewModel.setUp)
    }
}

struct SimplestAsyncPopoverView: View {
    @StateObject var viewModel = asyncViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.task {
            await viewModel.increment()
        }
    }
}

struct SimplestAsyncPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        SimplestAsyncPopoverView()
    }
}
