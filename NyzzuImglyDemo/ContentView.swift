//
//  ContentView.swift
//  NyzzuImglyDemo
//
//  Created by Jozsa Boglarka on 14.04.2025.
//

import IMGLYDesignEditor
import IMGLYEngine
import SwiftUI

struct ContentView: View {
   private let settings = EngineSettings(license: "TWVCQCdc4Sm3SWLyGhXQd2kh8tjGHN8rKGZW6xJjakhboTl4UApEok_iRg_X09H-") // License key
   
   var editor: some View {
       DesignEditor(settings)
           .imgly.onCreate { engine in
               try await setupEditor(engine: engine)
           }
   }
   
   @State private var isPresented = false
   
   var body: some View {
       Button("Use the Editor") {
           isPresented = true
       }
       .fullScreenCover(isPresented: $isPresented) {
           ModalEditor {
               editor
           }
       }
   }
   
   @MainActor
   private func setupEditor(engine: IMGLYEngine.Engine) async throws {
       let scene = try engine.scene.create()
       
       let page = try engine.block.create(.page)
       try engine.block.appendChild(to: scene, child: page)
       
       let block = try engine.block.create(.graphic)
       try engine.block.setShape(block, shape: engine.block.createShape(.star))
       try engine.block.setFill(block, fill: engine.block.createFill(.color))
       try engine.block.appendChild(to: page, child: block)
   }
}

struct ModalEditor<Editor: View, Label: View>: View {
   @ViewBuilder private let editor: () -> Editor
   @ViewBuilder private let dismissLabel: () -> Label
   
   init(@ViewBuilder editor: @escaping () -> Editor,
        @ViewBuilder dismissLabel: @escaping () -> Label = { SwiftUI.Label("Home", systemImage: "house") }) {
       self.editor = editor
       self.dismissLabel = dismissLabel
   }
   
   @State private var isBackButtonHidden = false
   @Environment(\.dismiss) private var dismiss
   
   @ViewBuilder private var dismissButton: some View {
       Button {
           dismiss()
       } label: {
           dismissLabel()
       }
   }
   
   var body: some View {
       NavigationView {
           editor()
               .onPreferenceChange(BackButtonHiddenKey.self) { newValue in
                   isBackButtonHidden = newValue
               }
               .toolbar {
                   ToolbarItem(placement: .navigationBarLeading) {
                       if !isBackButtonHidden {
                           dismissButton
                       }
                   }
               }
       }
       .navigationViewStyle(.stack)
   }
}

#Preview {
   ContentView()
}
