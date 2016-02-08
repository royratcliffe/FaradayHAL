// FaradayHALTests NestedResultsControllerTests.swift
//
// Copyright © 2016, Roy Ratcliffe, Pioneering Software, United Kingdom
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
import FaradayHAL
import HypertextApplicationLanguage

class NestedResultsControllerTests: ConnectionTests {

  func testAppLibrary() {
    // given
    let expectation = expectationWithDescription("App Library")
    let controller = NestedResultsController(connection: connection, relPath: "app:library")
    // when
    controller.onSuccess { (controller) -> Void in
      let root = controller.representations.first
      let appLibrary = controller.representations.last
      let appLibrarySelfLink = appLibrary?.link
      let rootAppLibraryLink = root?.linkFor("app:library")
      XCTAssertEqual(controller.representations.count, 2)
      XCTAssertNotNil(root)
      XCTAssertNotNil(appLibrary)
      XCTAssertNotNil(appLibrarySelfLink)
      XCTAssertNotNil(rootAppLibraryLink)
      XCTAssertEqual(rootAppLibraryLink?.href, appLibrarySelfLink?.href)
      expectation.fulfill()
    }
    controller.onFailure { (controller, env) -> Void in
      let response = env.response
      let body = response?.body
      let representation = body as? Representation
      XCTAssertNotNil(response)
      XCTAssertNotNil(body)
      XCTAssertNotNil(representation)
      XCTFail()
      expectation.fulfill()
    }
    // then
    waitForExpectationsWithTimeout(30.0) { (error) -> Void in
      if let error = error {
        NSLog("%@", error.localizedDescription)
      }
      XCTAssertNil(error)
    }
  }

  /// Expects failure. The root GET request delivers an `app:library` relation
  /// but its fetched representation does not deliver a relation called
  /// `no_rel`. Consequently the nested look-up fails.
  func testAppLibraryNoRel() {
    // given
    let expectation = expectationWithDescription("App Library No Rel")
    let controller = NestedResultsController(connection: connection, relPath: "app:library/no_rel")
    // when
    controller.onSuccess { (controller) -> Void in
      XCTFail()
      expectation.fulfill()
    }
    controller.onFailure { (controller, env) -> Void in
      expectation.fulfill()
    }
    // then
    waitForExpectationsWithTimeout(10.0) { (error) -> Void in
      if let error = error {
        NSLog("%@", error.localizedDescription)
      }
      XCTAssertNil(error)
    }
  }

}
