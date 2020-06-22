//
//  progressTests.swift
//  progressTests
//
//  Created by Erick Sanchez on 6/20/20.
//  Copyright © 2020 Erick Sanchez. All rights reserved.
//

import XCTest
@testable import progress

class PointsTests: XCTestCase {
  func testRank() {
    do {
      let rank = Points.rank(for: 0)
      XCTAssertEqual(rank.rank, 1)
      XCTAssertEqual(rank.points, 0)
      XCTAssertEqual(rank.pointsToNextLevel, 10)
      XCTAssertEqual(rank.totalPoints, 0)
    }
    do {
      let rank = Points.rank(for: 8)
      XCTAssertEqual(rank.rank, 1)
      XCTAssertEqual(rank.points, 8)
      XCTAssertEqual(rank.pointsToNextLevel, 10)
      XCTAssertEqual(rank.totalPoints, 8)
    }
    do {
      let rank = Points.rank(for: 10)
      XCTAssertEqual(rank.rank, 2)
      XCTAssertEqual(rank.points, 0)
      XCTAssertEqual(rank.pointsToNextLevel, 20)
      XCTAssertEqual(rank.totalPoints, 10)
    }
    do {
      let rank = Points.rank(for: 18)
      XCTAssertEqual(rank.rank, 2)
      XCTAssertEqual(rank.points, 8)
      XCTAssertEqual(rank.pointsToNextLevel, 20)
      XCTAssertEqual(rank.totalPoints, 18)
    }
    do {
      let rank = Points.rank(for: 28)
      XCTAssertEqual(rank.rank, 2)
      XCTAssertEqual(rank.points, 18)
      XCTAssertEqual(rank.pointsToNextLevel, 20)
      XCTAssertEqual(rank.totalPoints, 28)
    }
    do {
      let rank = Points.rank(for: 38)
      XCTAssertEqual(rank.rank, 3)
      XCTAssertEqual(rank.points, 8)
      XCTAssertEqual(rank.pointsToNextLevel, 40)
      XCTAssertEqual(rank.totalPoints, 38)
    }
    do {
      let rank = Points.rank(for: 38)
      XCTAssertEqual(rank.rank, 3)
      XCTAssertEqual(rank.points, 8)
      XCTAssertEqual(rank.pointsToNextLevel, 40)
      XCTAssertEqual(rank.totalPoints, 38)
    }
  }
}
