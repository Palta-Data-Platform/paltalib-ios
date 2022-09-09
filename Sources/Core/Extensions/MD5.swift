//
//  MD5.swift
//  PaltaLibCore
//
//  Created by Vyacheslav Beltyukov on 20/06/2022.
//

import Foundation
import CommonCrypto

//public extension Data {
//    var md5: String {
//        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
//        
//        let _: Void = digestData.withUnsafeMutableBytes { (digestBytes: UnsafeMutableRawBufferPointer) in
//            withUnsafeBytes { messageBytes in
//                CC_MD5(messageBytes, CC_LONG(count), digestBytes)
//            }
//        }
//        
//        return digestData
//    }
//}
