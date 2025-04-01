import SwiftUI
import PhotosUI
import UIKit

struct ContentView: View {
    @StateObject private var geminiService = GeminiAPIService(apiKey: "YOUR_API_KEY_HERE")
    @State private var prompt: String = ""
    @State private var selectedImage: UIImage?
    @State private var generatedImage: UIImage?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var imageSelection: PhotosPickerItem?
    @State private var showingPhotoPicker = false
    @State private var apiCallDuration: Double = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Selection
                    Button(action: { showingPhotoPicker = true }) {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            VStack {
                                Image(systemName: "photo.badge.plus")
                                    .font(.largeTitle)
                                Text("Select Image")
                                    .font(.headline)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                    .photosPicker(isPresented: $showingPhotoPicker,
                                selection: $imageSelection,
                                matching: .images)
                    .onChange(of: imageSelection) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImage = image
                            }
                        }
                    }
                    
                    // Prompt Input
                    TextField("Enter editing instructions...", text: $prompt, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                        .padding()
                    
                    // Generate Button
                    Button(action: generateImage) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text(isLoading ? "Editing..." : "Edit Image")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading || !isInputValid ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isLoading || !isInputValid)
                    }
                    .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                    }
                    
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // API call duration display
                    if apiCallDuration > 0 {
                        Text("Processing time: \(String(format: "%.2f", apiCallDuration)) seconds")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    
                    // Generated Image Display
                    if let generatedImage {
                        Image(uiImage: generatedImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding()
                    }
                }
            }
            .navigationTitle("Gemini Flash Edit")
        }
    }
    
    private var isInputValid: Bool {
        !prompt.isEmpty && selectedImage != nil
    }
    
    private func generateImage() {
        guard let selectedImage else { return }
        isLoading = true
        errorMessage = nil
        apiCallDuration = 0 // Reset timing
        
        Task {
            let startTime = Date()
            do {
                let response = try await geminiService.generateGeminiContent(prompt: prompt, image: selectedImage)
                
                // Calculate duration
                apiCallDuration = Date().timeIntervalSince(startTime)
                
                if let base64String = response.generatedImageData,
                   let imageData = Data(base64Encoded: base64String),
                   let image = UIImage(data: imageData) {
                    generatedImage = image
                } else {
                    errorMessage = "No image was generated in the response"
                }
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
                apiCallDuration = Date().timeIntervalSince(startTime)
            }
            
            isLoading = false
        }
    }
}

#Preview {
    ContentView()
}
