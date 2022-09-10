//
//  SimplestAsyncPopoverView.swift
//  AsyncPublisherTests
//
//  Created by Labtanza on 9/9/22.
//

import SwiftUI

class AsyncViewModel:ObservableObject {
    @Published var counter:Int = 0
    
    init() {
        print("hello")
    }
    
    deinit {
        print("goodbye")
    }
    
    
    
    //----- STEPS 3, 4, 6 -------
    public func increment() async {
        while counter < 8 {
           
            await MainActor.run {
                counter += 1
            }
            try? await  Task.sleep(nanoseconds: 2_000_000_000)
        }
    }
    
    //-------- STEP 3 ----------
    public func setUp()  {
        Task {
            await increment()
        }
    }
    
    //-------- STEP 4 ----------
    public func weakSetUp()  {
        Task { [weak self] in
            await self?.increment()
        }
    }
    
    //-------- STEP 5 ----------
    public func cancelCheckedWeakSetUp()  {
        Task { [weak self] in
            await self?.cancelCeckedIncrement()
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
    
    //-------- STEP 6 ----------
    private var counterTask: Task<(), Never>?
    
    public func instanceTaskSetUp() {
        counterTask = Task {
           await increment()
        }
    }
    
    public func tearDown() {
        counterTask?.cancel()
    }
    

}


//MARK: Step 2 View
struct SimplestAsyncPopoverView: View {
    @StateObject var viewModel = AsyncViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.task {
            await viewModel.increment()
        }
    }
}

//MARK: Step 3 View
struct AsyncPopoverSetupFuncView: View {
    @StateObject var viewModel = AsyncViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.onAppear(perform: viewModel.setUp)
    }
}

//MARK: Step 4 View
struct AsyncPopoverWeakSetupFuncView: View {
    @StateObject var viewModel = AsyncViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.onAppear(perform: viewModel.weakSetUp)
    }
}

//MARK: Step 5 View
struct AsyncPopoverCancelCheckedSetupFuncView: View {
    @StateObject var viewModel = AsyncViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.onAppear(perform: viewModel.cancelCheckedWeakSetUp)
    }
}

//MARK: Step 6 View
struct AsyncPopoverTaskKillerView: View {
    @StateObject var viewModel = AsyncViewModel()

    var body: some View {
        VStack {
            Text("\(viewModel.counter)")
            //Stepper("counter", value: $viewModel.counter)
        }.onDisappear(perform: viewModel.tearDown)
        .onAppear(perform: viewModel.instanceTaskSetUp)
    }
}
