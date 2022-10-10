//
//  CreateView.swift
//  TBD
//
//  Created by Sean P. Meek on 4/19/22.
//

import SwiftUI

struct CreateView: View {
    let gradient = LinearGradient(colors: [Color("MainColor"), Color(uiColor: .systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        ZStack {
            gradient
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                
            }
        }
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}
