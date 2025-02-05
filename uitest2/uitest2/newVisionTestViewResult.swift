//
//  newVisionTestViewResult.swift
//  uitest2
//
//  Created by Chun Wa Tang on 5/2/2025.
//
import SwiftUI
import AVFoundation
struct VisionTestResultView: View {
    let logMarValue: Double
    
    // Convert LogMAR to decimal acuity
    private func getDecimalAcuity(from logMAR: Double) -> Double {
        return pow(10, -logMAR)
    }
    
    // Convert LogMAR to Snellen (based on 6 meters)
    private func getSnellenNotation(from logMAR: Double) -> String {
        let decimalAcuity = getDecimalAcuity(from: logMAR)
        let denominator = Int(round(6 / decimalAcuity))
        return "6/\(denominator)"
    }
    
    // Get vision quality description
    private func getVisionQuality(from logMAR: Double) -> String {
        switch logMAR {
        case -0.01...0.01:
            return "Normal or Better"
        case 0.01...0.30:
            return "Mild Vision Loss"
        case 0.30...0.70:
            return "Moderate Vision Loss"
        case 0.70...1.00:
            return "Severe Vision Loss"
        default:
            return "Invalid"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Vision Test Results")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                ResultRow(title: "LogMAR Value", value: String(format: "%.2f", logMarValue))
                
                ResultRow(
                    title: "Decimal Acuity",
                    value: String(format: "%.2f", getDecimalAcuity(from: logMarValue))
                )
                
                ResultRow(
                    title: "Snellen Notation",
                    value: getSnellenNotation(from: logMarValue)
                )
                
                Divider()
                
                Text("Vision Assessment")
                    .font(.headline)
                Text(getVisionQuality(from: logMarValue))
                    .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .padding()
    }
}

struct ResultRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

// Preview provider for SwiftUI canvas
struct VisionTestResultView_Previews: PreviewProvider {
    static var previews: some View {
        VisionTestResultView(logMarValue: 0.2)
    }
}
