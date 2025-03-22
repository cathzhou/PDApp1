//
//  HomeView.swift
//  PDApp1
//
//  Created by Catherine Zhou on 3/22/25.
//

import SwiftUI
import Vision

struct HomeView: View {
    @State private var showingImagePicker = false
    @State private var extractedText = ""
    
    let selectedShift: String
    
    init(selectedShift: String) {
        self.selectedShift = selectedShift
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to your shift")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text("Your shift: \(selectedShift)")
                    .font(.title2)
                    .padding(.bottom, 20)
                
                Button("Scan Survey") {
                    showingImagePicker = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Text("Previous Scanned Surveys")
                    .font(.headline)
                    .padding(.top, 20)
                
                Text(extractedText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    NavigationLink(destination: PatientsView()) {
                        VStack {
                            Image(systemName: "person.3.fill")
                            Text("Patients")
                        }
                    }
                    .padding()
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    NavigationLink(destination: ResourcesView()) {
                        VStack {
                            Image(systemName: "book.fill")
                            Text("Resources")
                        }
                    }
                    .padding()
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    NavigationLink(destination: CalendarView()) {
                        VStack {
                            Image(systemName: "calendar")
                            Text("Scheduled Calls")
                        }
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            .padding()
            .sheet(isPresented: $showingImagePicker) {
                CameraView()
            }
        }
    }
    
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
            
            extractedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            
            print("Extracted Text: \(extractedText)")
            // Store the extracted text and username in UserDefaults
            UserDefaults.standard.set(extractedText, forKey: "extractedText")
            UserDefaults.standard.set(selectedShift, forKey: "selectedShift")
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
}

struct PatientsView: View {
    var body: some View {
        Text("Patients View")
    }
}

struct ResourcesView: View {
    var body: some View {
        Text("Resources View")
    }
}
