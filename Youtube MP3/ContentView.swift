//
//  ContentView.swift
//  Youtube MP3
//
//  Created by Erwan Martin on 07/07/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var playlistLink: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertText: String = ""
    @State private var savePath: String = ""
    @State private var infoText: String = ""
    @State var isRunning = false
    
    private func downloadPlaylist() {
        let dialog = NSOpenPanel();

        dialog.title = "Choisissez un dossier ou enregistrer la playlist";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = true;
        dialog.canChooseFiles = false;

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                savePath = result!.path
                do {
                    self.isRunning = true
                    let executableURL = URL(fileURLWithPath: "/bin/zsh")
                    let task = Process()
                    let connection = Pipe()
                    
                    task.executableURL = executableURL;
                    task.standardOutput = connection;
                    task.arguments = [
                        "-c",
                        "/opt/homebrew/bin/youtube-dl --add-header 'Cookie:' --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --output \"" + savePath + "/%(title)s.%(ext)s\" --yes-playlist '"+playlistLink+"'",
                    ];
                    task.terminationHandler = { _ in
                        self.isRunning = false
                    }
                
                    connection.fileHandleForReading.readabilityHandler = {
                        handle in
                        let data = handle.availableData;
                        let str = String(data: data, encoding: .ascii) ?? "<Non-ascii data of size\(data.count)>\n";
                        infoText = str;
                        print(infoText);
                    }
                    
                    try task.run();

                } catch {
                    self.isRunning = false;
                    alertText = "\(error)"
                    showingAlert = true;
                }
            }
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Téléchargez vos playlist youtube simplement !")
                .padding()
            VStack {
                HStack {
                    Text("Lien de la playlist")
                    TextField("ex : PLpkGh1KPUuCvNYoPEA8E-zs4pFRJOsdHB", text:$playlistLink)
                }
                HStack {
                    if(isRunning) {
                        Button("Téléchargement", action: {}).disabled(true)
                        ProgressView()
                            .padding(.leading)
                    } else {
                        Button("Télécharger", action: downloadPlaylist)
                    }
                }
                if(isRunning) {
                    Text(infoText)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .lineLimit(50)
                }
            }.padding([.leading, .bottom, .trailing])
        }
        .alert(self.alertText, isPresented: $showingAlert, actions: {
            Button("Ok", action: {})
        })
        .frame(width: 400.0)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
