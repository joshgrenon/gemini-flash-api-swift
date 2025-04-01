# Gemini Flash API Swift Demo

A SwiftUI-based iOS application that demonstrates image editing and modification using Google's Gemini Flash AI. This application provides a simple and intuitive interface for users to transform and edit their images using AI, guided by text prompts.

**Note: For now, you can simply drop the GeminiAPIService file into your own Xcode projects to use it. I'll consider converting this to a Swift Package Manager package if more people want to use it that way.**

## ⚠️ Disclaimer

**This is test/demo code only.** This implementation could stop working at any time if the Gemini API changes. This is not intended for production use and is provided as-is without any guarantees.

## Features

- 🎨 AI Image Editing: Transform and modify existing images using text instructions
- 🖼️ Image Input Required: Upload the image you want to edit
- 🔄 Image Transformation: Modify image style, content, and characteristics
- 📝 Text-Guided Editing: Use natural language to describe your desired image modifications

## What is Gemini Flash?

Gemini Flash is Google's AI model specifically designed for image editing and modification. Unlike traditional text-to-image generation, Gemini Flash specializes in transforming existing images based on text instructions while maintaining the core elements and structure of the original image.

## Setup

1. Clone the repository
2. Open the project in Xcode
3. Replace `YOUR_API_KEY_HERE` in `ContentView.swift` with your actual Gemini API key
4. Build and run the application

**Note:** This project has no external package dependencies - you only need a Gemini API key to get started.

## Running the Demo

### In Xcode Simulator
1. Select an iOS simulator from the device dropdown in Xcode (e.g., iPhone 15)
2. Click the Run button (▶️) or press Cmd+R
3. The app will build and launch in the simulator
4. Use the photo picker to select an image from the simulator's photo library
5. Test different prompts to see how Gemini Flash transforms images

## Integrating GeminiAPIService in Your Own Projects

To use the Gemini Flash API in your own Swift projects:

1. Copy the `GeminiAPIService.swift` file into your Xcode project
2. Initialize the service with your API key:
   ```swift
   let geminiService = GeminiAPIService(apiKey: "YOUR_API_KEY")
   ```
3. Call the image editing method with a base64-encoded image and your prompt:
   ```swift
   Task {
       let result = try await geminiService.editImage(
           imageBase64: encodedImageString,
           prompt: "Your editing instructions here"
       )
       // Handle the result...
   }
   ```
4. The API returns a base64-encoded string that you can convert back to an image:
   ```swift
   if let data = Data(base64Encoded: result), 
      let modifiedImage = UIImage(data: data) {
       // Use the modified image
   }
   ```

## Usage

1. Launch the application
2. Upload the image you want to edit
3. Enter your editing instructions in the text field (e.g., "Make this image more vibrant" or "Convert this to watercolor style")
4. Tap the "Edit Image" button
5. Wait for Gemini Flash to process and modify your image
6. The edited image will appear below the input field

## License

This project is licensed under the MIT License

## Acknowledgments

- Built with [Google's Gemini AI API](https://aistudio.google.com/)