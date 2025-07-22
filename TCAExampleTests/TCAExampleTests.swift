//
//  TCAExampleTests.swift
//  TCAExampleTests
//
//  Created by Harpreet Singh on 19/07/25.
//

import Testing
import ComposableArchitecture

@testable import TCAExample

@MainActor
struct TCAExampleTests {

    @Test 
    func basics() async throws {
        let store = TestStore(initialState: CounterFeature.State()) {
             CounterFeature()
           }
        
        await store.send(.incrementButtonTapped) {
            $0.counter = 1
        }
        await store.send(.decrementButtonTapped){
            $0.counter = 0
        }
    }
    
    @Test func timer() async throws {
        let clock = TestClock()
        let store = TestStore(initialState: CounterFeature.State()) {
             CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }
       
        await store.send(.toggleTimerButtonTapped) {
          $0.isTimerRunning = true
        }
        
        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick) {
          $0.counter = 1
        }
        await store.send(.toggleTimerButtonTapped) {
          $0.isTimerRunning = false
        }
    }
    
    @Test func numberFact() async throws {
        let store = TestStore(initialState: CounterFeature.State()) {
             CounterFeature()
        } withDependencies: {
            $0.numberFact.fetch = { "\($0) is a good number." }
        }
        
        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }
        
        await store.receive(\.factResponse, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
        }
    }

}
