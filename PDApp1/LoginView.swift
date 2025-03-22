//
//  LoginView.swift
//  PDApp1
//
//  Created by Catherine Zhou on 3/22/25.
//

import SwiftUI
import Vision
import CoreData

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var selectedShift: String
    /*
    var body: some View {
        VStack {
            TextField("Enter your name", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Login") {
                isLoggedIn = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
     */
    let formattedDate = Date().formatted()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Patient Discharge Initiative App")
                .font(.largeTitle)
            Text("Today's date is \(formattedDate)")
                .font(.title3)
                .foregroundColor(.gray)
                
            Text("Select your shift")
                .font(.title2)
            
            Picker("Shift", selection: $selectedShift){
                Section {
                    Text("Monday 1:30 PM-4:00 PM").tag(0)
                    Text("Monday 3:40 PM-6:10 PM").tag(1)
                } header: {
                    Text("Monday")
                }
                Section {
                    Text("Tuesday 1:30 PM-4:00 PM").tag(2)
                    Text("Tuesday 3:40 PM-6:10 PM").tag(3)
                } header: {
                    Text("Tuesday")
                }
                Section {
                    Text("Wednesday 3:40 PM-6:10 PM").tag(4)
                } header: {
                    Text("Wednesday")
                }
                Section {
                    Text("Thursday 1:30 PM-4:00 PM").tag(5)
                    Text("Thursday 3:40 PM-6:10 PM").tag(6)
                } header: {
                    Text("Thursday")
                }
                Section {
                    Text("Friday 1:30 PM-4:00 PM").tag(7)
                    Text("Friday 3:40 PM-6:10 PM").tag(8)
                } header: {
                    Text("Friday")
                }
                Section {
                    Text("Saturday 10 AM-12:30 PM").tag(9)
                    Text("Saturday 12:10 PM-2:40 PM").tag(10)
                } header: {
                    Text("Saturday")
                }
                Section {
                    Text("Sunday 10 AM-12:30 PM").tag(11)
                    Text("Sunday 12:10 PM-2:40 PM").tag(12)
                } header: {
                    Text("Sunday")
                }
            }
            Button(
                action: {
                    isLoggedIn = true
                },
                label: {
                    Text("Login")
                        .font(.system(size: 20, weight: .regular, design: .default))
                        .frame(maxWidth: 90, maxHeight: 40)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            )
        }
    }
     
    
}
