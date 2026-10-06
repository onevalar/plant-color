//
//  PlantSmallViewColor.swift
//  PlantWidgetExtension
//
//  Created by PlantColor on 2021/12/07.
//  Copyright © 2021 PlantColor. All rights reserved.

import SwiftUI

struct PlantSmallViewColor: View {

    var plant: PlantModel
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(plant.name).font(.largeTitle).bold().foregroundColor(Color(hex: "#FAC03D"))
            }
            HStack {
                VStack {
                    Text("Hex     \(plant.colorHEX)")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#FAC03D"))
                        .frame(width: 120, height: 10, alignment: .leading)
                    Text("RGB     \(plant.colorRGB.replacingOccurrences(of: ",", with: " "))")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#FAC03D"))
                        .frame(width: 120, height: 10, alignment: .leading)
                    Text("CMYK  \(plant.colorCMYK.replacingOccurrences(of: ",", with: " "))")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#FAC03D"))
                        .frame(width: 120, height: 10, alignment: .leading)
                }
            }
        }
    }
    
}
