# Gemini Flash API Swift Demo

A SwiftUI-based iOS application that demonstrates image editing and modification using Google's Gemini Flash AI. This application provides a simple and intuitive interface for users to transform and edit their images using AI, guided by text prompts.

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