//
//  FunFacts.swift
//  Smart Andover
//
//  Created by Chaniel Ezzi on 9/12/21.
//

import SwiftUI

struct FunFacts: View {
    
    @State private var currentFact: String
    @State private var usedFacts: [String]
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init () {
        let new = FunFacts.facts.randomElement()!
        currentFact = new
        usedFacts = [new]
    }
    
    var body: some View {
        
        (Text("Fun Fact! ").bold() + Text(currentFact))
            .id(currentFact)
            .transition(.slide)
            .onReceive(timer) { _ in
                withAnimation (.easeOut(duration: 0.3)) {
                    changeFact()
                }
            }
        
    }
    
    func changeFact () {
        
        if let new = FunFacts.facts.filter({ !usedFacts.contains($0) }).randomElement() {
            currentFact = new
            usedFacts.append(new)
        }
        else {
            currentFact = FunFacts.facts.filter({ $0 != currentFact }).randomElement()!
            usedFacts = [currentFact]
        }
        
    }
    
}

