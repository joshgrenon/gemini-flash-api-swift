import Foundation
import SwiftUI
import UIKit

@MainActor
class GeminiAPIService: ObservableObject {
    private let geminiApiKey: String
    
    init(apiKey: String) {
        self.geminiApiKey = apiKey
    }
    
    func generateGeminiContent(prompt: String, image: UIImage? = nil) async throws -> GeminiResponse {
        
        guard !geminiApiKey.isEmpty, geminiApiKey != "GEMINI_API_KEY" else {
            throw GeminiAPIError.missingAPIKeys
        }
        
        let modelId = "gemini-2.0-flash-exp-image-generation"
        let generateContentApi = "generateContent"
        
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(modelId):\(generateContentApi)?key=\(geminiApiKey)"
        guard let url = URL(string: urlString) else {
            throw GeminiAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build parts for the request
        var parts: [GeminiPart] = []
        
        // Add image content if provided
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            let base64Image = imageData.base64EncodedString()
            let inlineData = GeminiInlineData(mimeType: "image/jpeg", data: base64Image)
            let part = GeminiPart(text: nil, inlineData: inlineData)
            parts.append(part)
        }
        
        // Add text prompt
        let textPart = GeminiPart(text: prompt, inlineData: nil)
        parts.append(textPart)
        
        // Create request content
        let content = GeminiContent(role: "user", parts: parts)
        
        // Create generation config
        let generationConfig = GeminiGenerationConfig(
            responseModalities: ["image", "text"],
            responseMimeType: "text/plain",
            temperature: 0.4,
            topK: 32,
            topP: 1
        )
        
        // Create request body
        let geminiRequest = GeminiRequest(
            contents: [content],
            generationConfig: generationConfig
        )
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(geminiRequest)
            
            print("📤 Sending request to Gemini API...")
            print("📤 Request URL: \(urlString)")
            print("📤 Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw GeminiAPIError.invalidResponse
            }
            
            print("📥 Received response with status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error response body: \(errorString)")
                }
                throw GeminiAPIError.invalidResponse
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response body: \(responseString)")
            }
            
            let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            // Log if we successfully received image data
            if let imageData = geminiResponse.generatedImageData {
                print("✅ Successfully received image data in response")
                print("✅ Base64 image data length: \(imageData.count)")
                if let image = geminiResponse.getGeneratedImage() {
                    print("✅ Successfully converted base64 to UIImage")
                } else {
                    print("❌ Failed to convert base64 to UIImage")
                }
            } else {
                print("⚠️ No image data found in response")
                if let candidates = geminiResponse.candidates, !candidates.isEmpty {
                    let candidate = candidates[0]
                    print("⚠️ First candidate content parts count: \(candidate.content.parts?.count ?? 0)")
                    if let parts = candidate.content.parts {
                        for (index, part) in parts.enumerated() {
                            print("⚠️ Part \(index) - text: \(part.text != nil), inlineData: \(part.inlineData != nil)")
                            if let inlineData = part.inlineData {
                                print("⚠️ Part \(index) - mimeType: \(inlineData.mimeType ?? "nil")")
                            }
                        }
                    }
                } else {
                    print("⚠️ No candidates found in response")
                }
            }
            
            return geminiResponse
            
        } catch {
            print("❌ Gemini API error: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("❌ Decoding error: \(decodingError)")
            }
            throw error
        }
    }
}

// Error types for the API
enum GeminiAPIError: Error {
    case missingAPIKeys
    case invalidURL
    case invalidResponse
    case imageConversionError
}

// Response type for Gemini API
struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig
}

struct GeminiContent: Codable {
    let role: String?
    let parts: [GeminiPart]?
}

struct GeminiPart: Codable {
    let text: String?
    let inlineData: GeminiInlineData?
}

struct GeminiInlineData: Codable {
    let mimeType: String?
    let data: String?
}

struct GeminiGenerationConfig: Codable {
    let responseModalities: [String]
    let responseMimeType: String
    let temperature: Float?
    let topK: Int?
    let topP: Float?
    
    init(responseModalities: [String], responseMimeType: String, temperature: Float? = 0.4, topK: Int? = 32, topP: Float? = 1) {
        self.responseModalities = responseModalities
        self.responseMimeType = responseMimeType
        self.temperature = temperature
        self.topK = topK
        self.topP = topP
    }
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
    let promptFeedback: GeminiPromptFeedback?
    let usageMetadata: UsageMetadata?
    let modelVersion: String?
    
    struct GeminiCandidate: Codable {
        let content: GeminiContent
        let finishReason: String?
        let index: Int?
        let safetyRatings: [GeminiSafetyRating]?
    }
    
    struct GeminiPromptFeedback: Codable {
        let safetyRatings: [GeminiSafetyRating]?
    }
    
    struct GeminiSafetyRating: Codable {
        let category: String
        let probability: String
    }
    
    struct UsageMetadata: Codable {
        let promptTokenCount: Int?
        let totalTokenCount: Int?
        let promptTokensDetails: [PromptTokenDetail]?
    }
    
    struct PromptTokenDetail: Codable {
        let modality: String?
        let tokenCount: Int?
    }
    
    var generatedText: String? {
        candidates?.first?.content.parts?.compactMap { $0.text }.first
    }
    
    var generatedImageData: String? {
        candidates?.first?.content.parts?.compactMap { $0.inlineData?.data }.first
    }
    
    func getGeneratedImage() -> UIImage? {
        guard let base64String = generatedImageData, !base64String.isEmpty else {
            print("No image data found in response")
            return nil
        }
        
        guard let imageData = Data(base64Encoded: base64String) else {
            print("Failed to convert base64 to Data")
            return nil
        }
        
        return UIImage(data: imageData)
    }
} 
