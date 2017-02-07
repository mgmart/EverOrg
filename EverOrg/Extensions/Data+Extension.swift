//
//  Data+Extension.swift
//  EverOrg
//
//  Created by Mario Martelli on 06.02.17.
//  Copyright © 2017 Mario Martelli. All rights reserved.
//

import Foundation

extension Data {

  var hexString: String {
    return md5.map { String(format: "%02hhx", $0) }.joined()
  }

  var md5: Data {
    var result = Data(count: Int(CC_MD5_DIGEST_LENGTH))
    _ = result.withUnsafeMutableBytes {resultPtr in
      self.withUnsafeBytes {(bytes: UnsafePointer<UInt8>) in
        CC_MD5(bytes, CC_LONG(count), resultPtr)
      }
    }
    return result
  }
}
