// FaradayHAL DecodeJSON.swift
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

import Faraday
import HypertextApplicationLanguage

/// Decodes hypertext application language (HAL) responses. Adds
/// `application/hal+json` to the request's Accept header. Parses the response
/// body if the response's content type matches `application/hal+json`.
public class DecodeJSON: Response.Middleware {

  public var accepts = ["application/hal+json", "application/json"]

  public override func call(env: Env) -> Response {
    env.request?.headers.accepts(contentTypes: accepts)
    return super.call(env: env)
  }

  /// Handles response completion. Decodes the response if the content type
  /// matches expectations. Correct decoding requires an NSData response body as
  /// input.
  public override func onComplete(env: Env) {
    guard let response = env.response else {
      return super.onComplete(env: env)
    }
    guard let contentType = response.contentType, accepts.contains(contentType) else {
      return super.onComplete(env: env)
    }
    guard let data = response.body as? Data else {
      return super.onComplete(env: env)
    }
    var object: Any
    do {
      object = try JSONSerialization.jsonObject(with: data, options: [])
    } catch {
      return super.onComplete(env: env)
    }
    if let object = object as? NSDictionary {
      let representation = Representation()
      NSDictionaryRepresentationParser.parse(representation: representation, object: object)
      response.body = representation
    }
  }

  public class Handler: RackHandler {

    public init() {}

    public func build(app: @escaping App) -> Middleware {
      return DecodeJSON(app: app)
    }

  }

}
