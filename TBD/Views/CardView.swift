//
//  CardView.swift
//  TBD
//
//  Created by Sean P. Meek on 4/18/22.
//

import SwiftUI

struct CardView: View {
    @State private var rating: Int = 0
    
    var body: some View {
        VStack {
            VStack(spacing: 8) {
                Text("Beat Title")
                    .font(.system(size: 30))
                    .foregroundColor(.primary)
                
                Text("Producer name")
                    .font(.system(size: 20))
                    .cornerRadius(15)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            .padding(.bottom, 10)
            
            VStack {
                Image(systemName: "play.circle")
                    .foregroundColor(.primary)
                    .font(.system(size: 75))
                    .padding(.bottom, 8)
                
                Rectangle()
                    .frame(width: 250, height: 1)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 25)
            
            VStack {
                starView
                    .overlay(overlayView.mask(starView))
                    .padding(.bottom, 8)
                
                HStack(spacing: 25) {
                    Button {
                        rating = 0
                    } label: {
                        Text("Save")
                            .font(.system(size: 25))
                            .foregroundColor(Color(uiColor: .systemBackground))
                            .padding(5)
                            .padding(.horizontal)
                    }
                    .background(.primary)
                    .opacity(rating
                             == 0 ? 0.4 : 1)
                    .cornerRadius(10)
                    .padding(.vertical)
                    .disabled(rating == 0)
                    
                    Button {
                        rating = 0
                    } label: {
                        Text("Next")
                            .font(.system(size: 25))
                            .foregroundColor(.primary)
                            .padding(5)
                            .padding(.horizontal)
                            .background(Color("MainColor"))
                            .cornerRadius(10)
                            .padding(.vertical)
                    }
                    .disabled(rating == 0)
                    .opacity(rating
                             == 0 ? 0.4 : 1)
                }
            }
            .padding(.vertical, 20)
        }
        .padding(.vertical)
        .background(RoundedRectangle(cornerRadius: 25)
                        .fill(Color(uiColor: .systemBackground)))
    }
    
    private var overlayView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.yellow)
                    .frame(width: CGFloat(rating) / 5 * geometry.size.width)
            }
        }
        .allowsHitTesting(false)
    }
    
    private var starView: some View {
        HStack {
            ForEach(1..<6)  { index in
                Image(systemName: "star.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.gray)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            rating = index
                        }
                    }
            }
        }
    }
}


struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView()
    }
}
