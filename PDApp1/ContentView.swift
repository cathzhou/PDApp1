//
//  ContentView.swift
//  PDApp1
//
//  Created by Catherine Zhou on 3/22/25.
//

import SwiftUI
import Vision
import CoreData

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var selectedShift = ""
    
    var body: some View {
        if isLoggedIn {
            HomeView(selectedShift: selectedShift)
        } else {
            LoginView(isLoggedIn: $isLoggedIn, selectedShift: $selectedShift)
        }
    }
}