//
//  StringExtension.swift
//  CryptoConverter
//
//  Created by Dimitrios Karamanis on 21/12/2025.
//
import SwiftUI

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
