//
//  ViewModel.swift
//  SherpaOnnxTts
//
//  Created by fangjun on 2023/11/23.
//

import Foundation

// Define a struct to match the JSON structure of modelId
struct ModelPaths: Codable {
    let modelPath: String
    let tokensPath: String
    let dataDirPath: String
}

// Function to create the offline TTS wrapper by parsing modelId JSON
func createOfflineTts(modelId: String) -> SherpaOnnxOfflineTtsWrapper? {
    // Convert the JSON string to Data
    guard let data = modelId.data(using: .utf8) else {
        print("Kislaytts Invalid modelId string. Ensure it's a valid JSON.")
        return nil
    }
    
    // Decode the JSON into ModelPaths struct
    let decoder = JSONDecoder()
    let paths: ModelPaths
    do {
        paths = try decoder.decode(ModelPaths.self, from: data)
    } catch {
        print("Kislaytts Failed to decode modelId JSON: \(error)")
        return nil
    }
    
    print("Kislaytts Very good parsed till here");

    // Resolve paths from app bundle
    guard let bundlePath = Bundle.main.resourcePath else {
        print("Kislaytts Failed to get bundle resource path")
        return nil
    }

    let absoluteModelPath = (bundlePath as NSString).appendingPathComponent(paths.modelPath)
    let absoluteTokensPath = (bundlePath as NSString).appendingPathComponent(paths.tokensPath)
    let absoluteDataDirPath = (bundlePath as NSString).appendingPathComponent(paths.dataDirPath)

    print("Kislaytts Model path: \(absoluteModelPath)")
    print("Kislaytts Tokens path: \(absoluteTokensPath)")
    print("Kislaytts Data dir path: \(absoluteDataDirPath)")
    
    // Configure the VITS model
    let vitsConfig = sherpaOnnxOfflineTtsVitsModelConfig(
        model: absoluteModelPath,
        lexicon: "",
        tokens: absoluteTokensPath,
        dataDir: absoluteDataDirPath
    )
    
    // Configure the overall model configuration
    let modelConfig = sherpaOnnxOfflineTtsModelConfig(vits: vitsConfig)
    var config = sherpaOnnxOfflineTtsConfig(model: modelConfig)
    print("Kislaytts successfully created config");
    // Initialize and return the TTS wrapper
    return SherpaOnnxOfflineTtsWrapper(config: &config)
}
