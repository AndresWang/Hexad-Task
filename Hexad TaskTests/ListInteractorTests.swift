//
//  ListInteractorTests.swift
//  Hexad TaskTests
//
//  Created by Chieh Teng Wang on 10.05.19.
//  Copyright © 2019 Chieh Teng Wang. All rights reserved.
//

import XCTest
@testable import Hexad_Task

class ListInteractorTests: XCTestCase {
    var sut: ListInteractor!

    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        sut = ListInteractor()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Tests
    func testFetchDataShouldKeepDataInMemory() {
        // given
        XCTAssert(sut.favorites.value.count == 0)
        
        // when
        sut.fetchData()
        
        // then
        XCTAssert(sut.favorites.value.count > 0)
    }
    func testFetchDataShouldSortArrayWithHighestRatingAtTop() {
        // when
        sut.fetchData()
        
        // then
        let sortedDatas = sut.favorites.value[0].items.sorted{$0.rating > $1.rating}
        XCTAssertEqual(sut.favorites.value[0].items, sortedDatas)
    }
    func testTimerShouldSetAValidTimer() {
        // when
        sut.setTimer()
        
        // then
        XCTAssert(sut.timer?.isValid ?? false)
    }
    func testCancelTimerShouldInvalidateTimer() {
        // given
        sut.setTimer()
        
        // when
        sut.cancelTimer()
        
        // then
        if let timer = sut.timer {
            XCTAssertFalse(timer.isValid)
        } else {
            XCTFail("Timer should not be nil")
        }
    }
    func testUserDidSelectAnItemToRateShouldRegisterSelectedID() {
        // given
        sut.fetchData()
        let index = 0
        
        // when
        let _ = sut.userDidSelectAnItemToRate(index: index)
        
        // then
        XCTAssertEqual(sut.selectedID, sut.favorites.value[0].items[index].identity)
    }
    func testUserDidSelectAnItemToRateShouldReturnCorrectCurrentRating() {
        // given
        sut.fetchData()
        let index = 2
        
        // when
        let currentRating = sut.userDidSelectAnItemToRate(index: index)
        
        // then
        XCTAssertEqual(currentRating, sut.favorites.value[0].items[index].rating)
    }
    func testuserDidFinishRatingShouldUpdateRatingForTheItem() {
        // given
        sut.fetchData()
        let targetItem = sut.favorites.value[0].items[3]
        let newRating = targetItem.rating + 1 > 5 ? 1 : targetItem.rating + 1
        let selectedID = targetItem.identity
        sut.selectedID = targetItem.identity
        
        // when
        sut.userDidFinishRating(newRating: newRating)
        
        // then
        if let index = sut.favorites.value[0].items.firstIndex(where: {$0.identity == selectedID}) {
            let resultRating = sut.favorites.value[0].items[index].rating
            XCTAssertNil(sut.selectedID)
            XCTAssertEqual(resultRating, newRating)
        } else {
            XCTFail("We should have an index")
        }
    }
    func testuserDidFinishRatingShouldReSortTheArray() {
        // given
        sut.fetchData()
        var favoriteItems = sut.favorites.value[0].items
        let index = 3
        let targetItem = favoriteItems[index]
        let newRating = targetItem.rating + 1 > 5 ? 1 : targetItem.rating + 1
        sut.selectedID = targetItem.identity
        favoriteItems[index].rating = newRating
        
        // when
        sut.userDidFinishRating(newRating: newRating)
        
        // then
        let sortedArray = favoriteItems.sorted {$0.rating > $1.rating}
        XCTAssertEqual(sut.favorites.value[0].items, sortedArray)
    }
}
