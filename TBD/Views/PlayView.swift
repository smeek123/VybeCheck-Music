//
//  PlayView.swift
//  TBD
//
//  Created by Sean P. Meek on 4/19/22.
//

import SwiftUI

struct PlayView: View {
    let gradient = LinearGradient(colors: [Color("MainColor"), Color(uiColor: .systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        ZStack {
            gradient
                .ignoresSafeArea(.all)
            
            CardView()
        }
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView()
    }
}
