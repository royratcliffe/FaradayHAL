// FaradayHALTests FaradayHALTests.swift
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

import XCTest
@testable import FaradayHAL

import Faraday
import HypertextApplicationLanguage

class FaradayHALTests: XCTestCase {

  /// Encapsulates a fake adapter that merely remembers the request-response
  /// environments so that tests can subsequently save the finished responses
  /// artificially.
  class NothingAdapter: Adapter {

    static var envs = [Env]()

    /// The implementation instantiates a temporary `NothingAdapter` in order to
    /// save the responses. Only adapter instances know how to save and finish
    /// them. The temporary adapter does nothing, nor is it ever invoked as a
    /// member of a middleware stack. It just saves the responses just because
    /// it knows how.
    static func saveResponses(status: Int, body: Body?, headers: Headers) {
      let adapter = NothingAdapter { env -> Response in
        return Response()
      }
      while let env = envs.popLast() {
        adapter.saveResponse(env: env, status: status, body: body, headers: headers)
      }
    }

    override func call(env: Env) -> Response {
      NothingAdapter.envs.append(env)
      return app(env)
    }

    class Handler: RackHandler {

      func build(app: App) -> Middleware {
        return NothingAdapter(app: app)
      }

    }

  }

  func testNothingAdapter() {
    // given
    let connection = Connection()
    connection.use(handler: FaradayHAL.EncodeJSON.Handler())
    connection.use(handler: Faraday.Logger.Handler())
    connection.use(handler: NothingAdapter.Handler())
    // when
    let _ = connection.get().onComplete { env in
      XCTAssertNotNil(env.request)
      XCTAssertNotNil(env.response)
      XCTAssertEqual(env.request?.method, "GET")
      XCTAssertEqual(env.response?.status, 0)
    }
    // then
    NothingAdapter.saveResponses(status: 0, body: nil, headers: Headers())
  }

  func testEncodeJSON() {
    // given
    let connection = Connection()
    connection.use(handler: FaradayHAL.EncodeJSON.Handler())
    connection.use(handler: Faraday.Logger.Handler())
    connection.use(handler: NothingAdapter.Handler())
    // when
    let response = connection.post { request in
      let representation = Representation()
      let _ = representation.with(link: Link(rel: Link.SelfRel, href: "http://localhost/path/to/self"))
      request.body = representation
    }
    let _ = response.onComplete { env in
      XCTAssertNotNil(env.request)
      XCTAssertNotNil(env.response)

      XCTAssertEqual(env.request?.method, "POST")
      XCTAssertEqual(env.response?.status, 0)

      XCTAssertNotNil(env.request?.body)
      XCTAssertNotNil(env.request?.body as? NSData)
    }
    // then
    NothingAdapter.saveResponses(status: 0, body: nil, headers: Headers())
  }

}
