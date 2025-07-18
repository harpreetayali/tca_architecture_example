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
    struct State {
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
                        let (data, _) = try await URLSession.shared
                            .data(from: URL(string: "http://numbersapi.com/\(count)")!)
                        
                        let fact = String(decoding: data, as: UTF8.self)
                        await send(.factResponse(fact))
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
                        while true {
                            try await Task.sleep(for: .seconds(1))
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

