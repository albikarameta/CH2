//
//  ScanDomunetView.swift
//  OCR
//  Created by Albi Karameta on 11/11/25.
//


import Foundation
import SwiftUI
import VisionKit
import Vision

struct ScanDomunetView: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode  // lets you dismiss the sheet after scanning
    
    @Binding var recognisedText: String  // sends scanned OCR text back to the parent view
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognisedText: $recognisedText, parent: self)  // SwiftUI uses a Coordinator to communicate between UIKit and SwiftUI.
    }
    
    func makeUIViewController(context: Context) ->  VNDocumentCameraViewController { // Creates Apple’s built-in document scanner
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController                          // Sets Coordinator as the delegate to receive scan results
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {  // This class receives scanned pages and runs OCR on them.
        var recognisedText: Binding<String>  // send text back to SwiftUI
        var parent: ScanDomunetView  // dismiss the view
        
        init(recognisedText: Binding<String>, parent: ScanDomunetView) {
            self.recognisedText = recognisedText
            self.parent = parent
        }
// Called when user taps "Done".
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            
            let extractedImages = extractImages(from: scan)  // Extract pages as CGImage
            
            let processedText = recongiseText(from: extractedImages)  // Run OCR on them
            
            recognisedText.wrappedValue = processedText  // Return result to SwiftUI
            
            parent.presentationMode.wrappedValue.dismiss()  // Close the scanner sheet
        }
// Extract images from document scan
        fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            
            var extractedImages = [CGImage]()  // Create an empty array to store scanned pages.
            
            for index in 0..<scan.pageCount {  // Loop through all scanned pages.
                
                let extractedImage = scan.imageOfPage(at: index)  // Get each page as a UIImage.
                
                guard let cgImage = extractedImage.cgImage else {  // OCR requires a CGImage, so this converts it.
                    
                    continue
            }
            
            extractedImages.append(cgImage)  // Add to array.
        }
        
        return extractedImages
    }
// Recognize text using Vision OCR
        fileprivate func recongiseText(from images: [CGImage]) -> String {
        var entireRecognisedText = ""  // This will accumulate text from all pages.
        
        let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in  // This closure runs after Vision finishes scanning a page.
            
            guard error == nil else { return }  // Ignore if error occurs.
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }  // OCR results come as text observations.
            
// Extract the best text candidate
        let maximumRecognitionCandidates = 1  // You only want the most confident prediction.
            
            for ovbservation in observations {
                
                guard let candidate = ovbservation.topCandidates(maximumRecognitionCandidates).first else { continue }
                
                entireRecognisedText += "\(candidate.string)\n"
// For each detected chunk of text:
                
       //                   take the best recognized version

      //                    append it to the full text string (with newline)
            }
        }
        
            recognizeTextRequest.recognitionLevel = .accurate  // Better accuracy → slower performance.
            // Process each image
        for image in images {
            
            let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
            
            try? requestHandler.perform([recognizeTextRequest])
            // Runs OCR on every scanned page.
        }

            return entireRecognisedText  // Return all recognized text
        }
    }
}
