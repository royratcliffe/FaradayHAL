// FaradayHAL Faraday/Response.swift
//
// Copyright © 2015, Roy Ratcliffe, Pioneering Software, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the “Software”), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

import Faraday
import HypertextApplicationLanguage

extension Response {

  /// Extends the Faraday Response class with an onRepresentation method. Adds a
  /// special representation-oriented completion call-back to the response
  /// call-back stack. Use this to select and redirect HAL representation
  /// responses. It assumes that the connection middleware stack includes the
  /// HAL decoder; otherwise it never responds.
  ///
  /// What happens if the response body is not a representation? Invokes the
  /// given handler if, and only if, the response contains a
  /// representation. Throws away the response otherwise. Only considers the
  /// response body if the response is successful, that is, if the status code
  /// lies between 200 and 299 inclusive. Outside that range, no attempt to
  /// type-cast the body to a HAL representation occurs.
  public func onRepresentation(callback: (Representation) -> Void) -> Response {
    onSuccess { (env) -> Void in
      if let representation = env.response?.body as? Representation {
        callback(representation)
      }
    }
    return self
  }

}
