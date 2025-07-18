//
//  TCAExampleApp.swift
//  TCAExample
//
//  Created by Harpreet Singh on 16/07/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCAExampleApp: App {
    
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
    }
                             
    var body: some Scene {
        WindowGroup {
            CounterView(store: TCAExampleApp.store)
        }
    }
}
