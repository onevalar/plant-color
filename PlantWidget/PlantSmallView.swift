//
//  PlantSmallView.swift
//  PlantWidgetExtension
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.

import SwiftUI

struct PlantSmallView: View {

    var plant: PlantModel
    
    var body: some View {

        ZStack(alignment: .topLeading) {
            Color.init(hex: plant.colorHEX)
            
            if plant.showFigure {
                Image(plant.imageName)
                    .resizable()
                    .frame(width: 35, height: 35, alignment: .center)
                    .offset(x:104, y:27)
                    .foregroundColor(.clear)
            }
            
            Text(plant.name)
                .font(.custom("PingFangSC-Semibold", size: plant.name.count > 2 ? 25 : 35))
                .foregroundColor(Color.init(hex: plant.textColor))
                .frame(width: 85, height: 50, alignment: .leading)
                .offset(x:15,y:20)
            
            if plant.customContent.isEmpty {
                if plant.showTone {
                    Text("Hex     \(plant.colorHEX)")
                        .font(.custom("PingFangSC-Regular", size: 11))
                        .foregroundColor(Color.init(hex: plant.textColor))
                        .frame(width: 120, height: 10, alignment: .leading)
                        .offset(x:19, y:90)

                    Text("RGB     \(plant.colorRGB.replacingOccurrences(of: ",", with: " "))")
                        .font(.custom("PingFangSC-Regular", size: 11))
                        .foregroundColor(Color.init(hex: plant.textColor))
                        .frame(width: 120, height: 10, alignment: .leading)
                        .offset(x:19, y:105)

                    Text("CMYK  \(plant.colorCMYK.replacingOccurrences(of: ",", with: " "))")
                        .font(.custom("PingFangSC-Regular", size: 11))
                        .foregroundColor(Color.init(hex: plant.textColor))
                        .frame(width: 120, height: 10, alignment: .leading)
                        .offset(x:19, y:120)

                }
            } else {
                Text(plant.customContent)
                    .font(.custom("PingFangSC-Regular", size: 14))
                    .foregroundColor(Color.init(hex: plant.textColor))
                    .lineLimit(3)
                    .frame(width: 120, height: 60, alignment: .leading)
                    .offset(x:19, y:70)
            }

        }
    }
    
}
