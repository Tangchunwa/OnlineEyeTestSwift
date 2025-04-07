//
// VisionTestResultView.swift
// Visual Test Result UI
//
// Created by Chun Wa Tang on 17/2/2025.
//

import SwiftUI
import AVFoundation

struct VisionTestResultView: View {
    let rightEyeLogMAR: Double
    let leftEyeLogMAR: Double
    
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
            return "normal_or_better".localized
        case 0.01...0.29:
            return "mild_vision_loss".localized
        case 0.30...0.49:
            return "moderate_vision_loss".localized
        case 0.50...1.00:
            return "severe_vision_loss".localized
        default:
            return "invalid".localized
        }
    }
    
    // Get color for vision quality
    private func getQualityColor(from logMAR: Double) -> Color {
        switch logMAR {
        case -0.01...0.01:
            return .green
        case 0.01...0.29:
            return .blue
        case 0.30...0.49:
            return .orange
        case 0.50...1.00:
            return .red
        default:
            return .gray
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Title
                Text("vision_test_results".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Right Eye Results
                ResultCard(
                    eye: "right_eye".localized,
                    logMAR: rightEyeLogMAR,
                    decimalAcuity: getDecimalAcuity(from: rightEyeLogMAR),
                    //snellenNotation: getSnellenNotation(from: rightEyeLogMAR),
                    visionQuality: getVisionQuality(from: rightEyeLogMAR),
                    qualityColor: getQualityColor(from: rightEyeLogMAR)
                )
                
                // Left Eye Results
                ResultCard(
                    eye: "left_eye".localized,
                    logMAR: leftEyeLogMAR,
                    decimalAcuity: getDecimalAcuity(from: leftEyeLogMAR),
                    //snellenNotation: getSnellenNotation(from: leftEyeLogMAR),
                    visionQuality: getVisionQuality(from: leftEyeLogMAR),
                    qualityColor: getQualityColor(from: leftEyeLogMAR)
                )
                
            }
            .padding()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ResultCard: View {
    let eye: String
    let logMAR: Double
    let decimalAcuity: Double
    //let snellenNotation: String
    let visionQuality: String
    let qualityColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(eye)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "eye.fill")
                    .foregroundColor(qualityColor)
            }
            
            Divider()
            
            ResultRow(title: "logmar_value".localized, value: logMAR >= 0.5 ? "N/A" : String(format: "%.2f", logMAR))
            ResultRow(title: "decimal_acuity".localized, value: decimalAcuity <= 0.33 ? "N/A" : String(format: "%.2f", decimalAcuity))
            //ResultRow(title: "snellen_notation".localized, value: snellenNotation)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 5) {
                Text("vision_quality".localized)
                    .fontWeight(.medium)
                Text(visionQuality)
                    .foregroundColor(qualityColor)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 5)
        )
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

struct InfoRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .fontWeight(.semibold)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

// Preview provider for SwiftUI canvas
struct VisionTestResultView_Previews: PreviewProvider {
    static var previews: some View {
        VisionTestResultView(rightEyeLogMAR: 0.2, leftEyeLogMAR: 0.3)
    }
}
