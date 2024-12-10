//  ImageView.swift
//  With-OpenAI
//
//  Created by ryo fujimura on 2024/12/3.
//

import SwiftUI

struct ImageView: View {
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

#Preview {
    ImageView()
}
