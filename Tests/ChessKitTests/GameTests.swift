//
//  GameTests.swift
//  ChessKitTests
//

import XCTest
@testable import ChessKit

class GameTests: XCTestCase {
    
    private let game = Game()
    
    // MARK: - Indices used in tests
    
    private let nf3Index = MoveTree.Index(number: 2, color: .white, variation: 0)
    private let nc3Index = MoveTree.Index(number: 2, color: .white, variation: 1)
    private let nf6Index = MoveTree.Index(number: 2, color: .black, variation: 1)
    private let nc6Index = MoveTree.Index(number: 2, color: .black, variation: 2)
    private let nc6Index2 = MoveTree.Index(number: 2, color: .black, variation: 0)
    private let f5Index = MoveTree.Index(number: 2, color: .black, variation: 3)
    
    // MARK: - Setup
    
    override func setUp() {
        game.make(moves: ["e4", "e5", "Nf3", "Nc6", "Bc4"])
        
        // add 2. Nc3 ... variation to 2. Nf3
        game.make(moves: ["Nc3", "Nf6", "Bc4"], from: nf3Index.previous)
        
        // add 2... Nc6 ... variation to 2... Nf6
        game.make(moves: ["Nc6", "f4"], from: nf6Index.previous)
        
        // add another variation to 2... Nf6
        game.make(moves: ["f5", "exf5"], from: nc6Index2.previous)
    }
    
    // MARK: - Test cases
    
    func testMakeMoves() {
        XCTAssertEqual(game.moves[.init(number: 1, color: .white)]?.san, "e4")
        XCTAssertEqual(game.moves[.init(number: 1, color: .black)]?.san, "e5")
        XCTAssertEqual(game.moves[.init(number: 2, color: .white)]?.san, "Nf3")
        XCTAssertEqual(game.moves[.init(number: 2, color: .black)]?.san, "Nc6")
        XCTAssertEqual(game.moves[.init(number: 3, color: .white)]?.san, "Bc4")
    }
    
    func testMoveTree() {
        XCTAssertEqual(game.moves[nf3Index]?.san, "Nf3")
        XCTAssertEqual(game.moves[nc3Index]?.san, "Nc3")
        
        XCTAssertEqual(game.moves[nf6Index]?.san, "Nf6")
        XCTAssertEqual(game.moves[nc6Index]?.san, "Nc6")

        XCTAssertEqual(
            game.moves.previousIndex(
                for: nc6Index
            ),
            nc3Index
        )
        
        XCTAssertEqual(game.moves[nc6Index2]?.san, "Nc6")
        XCTAssertEqual(game.moves[f5Index]?.san, "f5")

        XCTAssertEqual(
            game.moves.previousIndex(
                for: f5Index
            ),
            nf3Index
        )
    }
    
    func testMoveAnnotation() {
        game.moves.annotate(moveAt: nc3Index, assessment: .brilliant)
        game.moves[f5Index]?.comment = "Comment test"
        
        XCTAssertEqual(
            PGNParser.convert(game: game),
            "1. e4 e5 2. Nf3 (2. Nc3 $3 Nf6 (2... Nc6 3. f4) 3. Bc4) Nc6 (2... f5 {Comment test} 3. exf5) 3. Bc4"
        )
    }
    
    func testMoveIndexHistory() {
        let f5History = game.moves.history(for: f5Index)
        
        XCTAssertEqual(
            f5History,
            [
                .init(number: 1, color: .white, variation: 0),
                .init(number: 1, color: .black, variation: 0),
                .init(number: 2, color: .white, variation: 0),
                f5Index,
            ]
        )
    }
    
}
