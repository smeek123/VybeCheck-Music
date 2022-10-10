//
//  DiscoverView.swift
//  TBD
//
//  Created by Sean P. Meek on 4/21/22.
//

import SwiftUI

struct DiscoverView: View {
    let gradient = LinearGradient(colors: [Color("MainColor"), Color(uiColor: .systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        NavigationView {
            ZStack {
                gradient
                    .ignoresSafeArea(.all)
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.primary)
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
