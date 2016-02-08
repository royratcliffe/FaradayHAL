// FaradayHAL NestedResultsController.swift
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

import Foundation
import Faraday
import HypertextApplicationLanguage

/// Fetches nested representations.
///
/// The nested results controller is a controller class that accesses a nested
/// sequence of representations based on a given relation path. Relation paths
/// represent one or more hypertext-application-language (HAL) link
/// relations. Forward slashes delimit the relations within the path.
///
/// Uses one or more consecutive GET requests to access a specific resource
/// representation.
public class NestedResultsController: NSObject {

  public var connection: Connection!

  /// Optional base link. Its reference defines the initial GET location for the
  /// connection. If not present, the controller initially pulls on the
  /// connection without a path. This assumes that the connection URL already
  /// includes a path, if one is needed.
  public var link: Link?

  public func fetch() -> Self {
    if response == nil {
      response = responseForRel
    }
    return self
  }

  public convenience init(connection: Connection, relPath: String) {
    self.init()
    self.connection = connection
    self.relPath = relPath
    fetch()
  }

  // MARK: - Handlers

  public typealias SuccessHandler = ((NestedResultsController) -> Void)

  public typealias FailureHandler = ((NestedResultsController, Env) -> Void)

  public var successHandler: SuccessHandler?

  public var failureHandler: FailureHandler?

  /// Sets up the success handler.
  public func onSuccess(successHandler: SuccessHandler) -> Self {
    self.successHandler = successHandler
    return self
  }

  /// Sets up the failure handler.
  public func onFailure(failureHandler: FailureHandler) -> Self {
    self.failureHandler = failureHandler
    return self
  }

  // MARK: - Relations

  public internal(set) var rels = [String]()

  public internal(set) var relIndex = 0

  /// Setting up the relation path also resets the relation index and shuts down
  /// any concurrently operating request-response cycle. In short, you cannot
  /// change the relation path without stopping the nested fetch operation. The
  /// path remains mutable while running the nested fetch but changing it
  /// terminates the fetch.
  public var relPath: String {
    get {
      return rels.joinWithSeparator("/")
    }
    set(relPath) {
      rels = relPath.componentsSeparatedByString("/")

      // Terminate the fetch.
      relIndex = 0
      response = nil
    }
  }

  var hasRel: Bool {
    return relIndex < rels.count
  }

  /// - returns: the relation to look up next. Answers `nil` if there is no next
  ///   relation. Consumes the next relation, therefore use `hasRel` first to
  ///   determine if another relation needs looking up.
  var rel: String? {
    guard hasRel else {
      return nil
    }
    return rels[relIndex++]
  }

  /// Checks for a representation first, before asking for the next relation.
  /// - returns: a link to use for the next nested fetch.
  var linkForRel: Link? {
    guard let representation = representations.last else {
      return link ?? Link(rel: "", href: "")
    }
    guard let rel = rel else {
      return nil
    }
    return representation.linkFor(rel)
  }

  /// Runs a new request-response cycle for the next nested representation.
  /// - returns: a new unfinished response for the next nested fetch. The fetch
  ///   starts automatically and runs concurrently when the getter returns.
  var responseForRel: Response? {
    guard let link = linkForRel else {
      return nil
    }
    return connection.get(link.href).onSuccess({ [weak self] (env) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        guard let strongSelf = self where strongSelf.finishResponse(env) else {
          return
        }
        guard let representation = env.response?.body as? Representation else {
          strongSelf.failureHandler?(strongSelf, env)
          return
        }
        strongSelf.nest(representation, env: env)
      }
    }).onFailure({ [weak self] (env) -> Void in
      guard let strongSelf = self where strongSelf.finishResponse(env) else {
        return
      }
      strongSelf.failureHandler?(strongSelf, env)
    })
  }

  // MARK: - Representations

  /// Nested results.
  public internal(set) var representations = [Representation]()

  /// Consumes the next pending relation.
  ///
  /// Runs the success handler when there are no more relations to look up. Runs
  /// the failure handler when there is a relation to look up but the latest
  /// representation does not contain that relation. This happens when the
  /// relation path does not match reality. The remote end-point has presented
  /// some representation along the path which does not contain a relation
  /// matching the expected relation.
  func nest(representation: Representation, env: Env) {
    //
    //    mutableArrayValueForKey("representations").addObject(representation)
    //
    // Instead, add the new representation using Swift's array append method. Do
    // Swift array methods trigger key-value observations? Clients may want to
    // observe the representations one-by-one as they download and appear.
    representations.append(representation)
    if hasRel {
      response = responseForRel
      if response == nil {
        failureHandler?(self, env)
      }
    }
    else {
      successHandler?(self)
    }
  }

  // MARK: - Response

  var response: Response?

  /// Finishes the running response using the given environment.
  /// - returns: true if the finished response carried by the given environment
  ///   corresponds to the pending response. Disconnects the finished response
  ///   if so. Environment response and pending response only fail to match when
  ///   the controller has reset the relation path and stopped retaining the
  ///   pending response. The environment response finishes but has become an
  ///   unwanted orphan, and in this case the answer is false.
  func finishResponse(env: Env) -> Bool {
    guard let response = env.response where response === self.response else {
      return false
    }
    self.response = nil
    return true
  }

}
