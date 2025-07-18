//
//  CounterFeature.swift
//  TCAExample
//
//  Created by Harpreet Singh on 16/07/25.
//

import ComposableArchitecture

@Reducer
struct CounterFeature {
    
    @ObservableState
    struct State {
        var counter: Int = 0
    }
    
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.counter -= 1
                return .none
            case .incrementButtonTapped:
                state.counter += 1
                return .none
            }
        }
    }
}

