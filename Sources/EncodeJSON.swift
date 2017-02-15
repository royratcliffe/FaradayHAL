// FaradayHAL EncodeJSON.swift
//
// Copyright © 2015, 2016, Roy Ratcliffe, Pioneering Software, United Kingdom
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

import Foundation
import Faraday
import HypertextApplicationLanguage

/// Encodes a hypertext application language (HAL) representation body to
/// JSON. Does nothing if the body is not a HAL representation.
public class EncodeJSON: Faraday.Middleware {

  public override func call(env: Env) -> Response {
    guard let request = env.request else {
      return super.call(env: env)
    }
    guard let body = request.body as? Representation else {
      return super.call(env: env)
    }
    guard request.headers["Content-Type"] == nil else {
      return super.call(env: env)
    }
    let object = NSDictionaryRepresentationRenderer.render(representation: body)
    if let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
      request.headers["Content-Type"] = "application/hal+json"
      request.body = data
    }
    return app(env)
  }

  public class Handler: RackHandler {

    public init() {}

    public func build(app: @escaping App) -> Middleware {
      return EncodeJSON(app: app)
    }

  }

}
