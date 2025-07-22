//
//  CounterFeature.swift
//  TCAExample
//
//  Created by Harpreet Singh on 16/07/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CounterFeature {
    
    @ObservableState
    struct State: Equatable {
        var counter: Int = 0
        var fact: String?
        var isLoading: Bool = false
        var isTimerRunning: Bool = false
    }
    
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case factButtonTapped
        case toggleTimerButtonTapped
        case factResponse(String)
        case timerTick
    }
    
    enum CancelID { case timer }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.numberFact) var numberFact
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .decrementButtonTapped:
                state.counter -= 1
                state.fact = nil
                return .none
                
            case .incrementButtonTapped:
                state.counter += 1
                state.fact = nil
                return .none
                
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                
                return .run { [count = state.counter] send in
                    do {
                        try await send(.factResponse(self.numberFact.fetch(count)))
                    }catch {
                        await send(.factResponse(error.localizedDescription))
                    }
                }
            case let .factResponse(fact):
                state.fact = fact
                state.isLoading = false
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                }else {
                    return .cancel(id: CancelID.timer)
                }
               
                
            case .timerTick:
                state.counter += 1
                state.fact = nil
                return .none
            }
            
        }
    }
}

