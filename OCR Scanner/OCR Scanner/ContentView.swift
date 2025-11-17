//
//  ContentView.swift
//  OCR
//
//  Created by Albi Karameta on 09/11/25.
//

import SwiftUI
// Defines the main screen of my app.
struct ContentView: View {
    @State private var recognisedText = "Press 'Start Scanning'"  // Holds the OCR text that comes from the scanner
    @State private var showScanningViiew = false  // Controls whether the scanner sheet is visible
    let buttonHeight: CGFloat = 50  // A constant used to keep both buttons the same height
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                ScrollView {  // Creates a card-like white rounded rectangle
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white)
                            .shadow(radius: 3)
                        Text(recognisedText)
                            .padding()
                    }
                    .padding()
                }
                
                Spacer()
                HStack(spacing: 20) {
                    
                    Button(action: {
                        self.showScanningViiew = true
                    }) {
                        Text("Start Scanning")
                            .padding()
                            .foregroundColor(.white)
                            .background(Capsule().fill(.blue))
                    }
                    
                    Button(action: {
                        self.copyToClipboard()
                    }) {
                        Text("Copy Text")
                            .buttonStyle(.glassProminent)
                            .padding()
                            .foregroundColor(.white)
                            .background(Capsule().fill(.gray))
                    }
                    .disabled(recognisedText == "Tap Button To Start Scanning")
                }
                .padding()
            }
            .background(.gray.opacity(0.1))
            .navigationBarTitle("OCR Scanner")
            .sheet(isPresented: $showScanningViiew) {  // Shows the ScanDocumentView when showScanningView == true
                ScanDomunetView(recognisedText: self.$recognisedText)
            }
        }
    }
// Copies the OCR output to the device clipboard.
    private func copyToClipboard() {
        UIPasteboard.general.string = recognisedText
    }
}
#Preview {
    ContentView()
}
