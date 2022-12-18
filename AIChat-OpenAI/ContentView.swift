//
//  ContentView.swift
//  AIChat-OpenAI
//
//  Created by ryofuji on 12/15/22.
//

import OpenAIKit
import SwiftUI

final class ViewModel: ObservableObject {
    private var openai: OpenAI?
    
    func setup() {
        openai = OpenAI(Configuration(
            organization: "Personal",
            apiKey: "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"
        ))
    }

    func generateImage(prompt: String) async -> UIImage? {
        guard let openai = openai else {
            return nil
        }
        do {
            let params = ImageParameters(
                prompt: prompt,
                resolution: .medium,
                responseFormat: .base64Json
            )
            let result = try await openai.createImage(
                parameters: params
            )
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
            
        }
        catch {
            print(String(describing: error))
            return nil
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    
    @State private var bgColor = Color.white
    
    var body: some View {
        NavigationView{
            VStack{
                Spacer()
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                    //                        .frame(width: 1284, height: 1284)
                }
                else {
                    Text("Here you go.")
                }
                Spacer()
                TextField("Type prompt here...", text: $text)
                    .padding()
                ColorPicker("Set the background color", selection: $bgColor)
                
                Button("Go"){
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        Task {
                            let result = await viewModel.generateImage(prompt: text)
                            if result == nil {
                                print("Fail.")
                            }
                            self.image = result
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(bgColor)
//            .navigationTitle("Dare no image")
            .onAppear{
                viewModel.setup()
            }
//            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
