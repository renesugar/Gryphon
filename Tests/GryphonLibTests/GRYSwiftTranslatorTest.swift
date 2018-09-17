/*
* Copyright 2018 Vinícius Jorge Vendramini
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

@testable import GryphonLib
import XCTest

class GRYSwiftTranslatorTest: XCTestCase {
	func testTranslator() {
		let tests = TestUtils.allTestCases

		for testName in tests {
			print("- Testing \(testName)...")

			// Create the Gryphon AST using the mock Swift AST
			let testFilePath = TestUtils.testFilesPath + testName
			let swiftAst = GRYSwiftAst.initialize(fromJsonInFile: testFilePath + .grySwiftAstJson)
			let createdGryphonAst = GRYSwift4_1Translator().translateAST(swiftAst)!

			// Load the previously stored Gryphon AST from file
			let expectedGryphonAstJson = try! String(contentsOfFile: testFilePath + .gryAstJson)
			let expectedGryphonAstData = Data(expectedGryphonAstJson.utf8)
			let expectedGryphonAst =
				try! JSONDecoder().decode(GRYSourceFile.self, from: expectedGryphonAstData)

			XCTAssert(
				createdGryphonAst == expectedGryphonAst,
				"Test \(testName): translator failed to produce expected result. Diff:" +
					TestUtils.diff(createdGryphonAst.description, expectedGryphonAst.description))

			print("\t- Done!")
		}
	}

	// TODO: Improve this test (early failures probably mean almost nothing is getting tested)
	func testEquatable() {
		let tests = TestUtils.allTestCases

		let swiftAsts = tests.map { testName -> GRYSwiftAst in
			let testFilePath = TestUtils.testFilesPath + testName
			return GRYSwiftAst.initialize(fromJsonInFile: testFilePath + .grySwiftAstJson)
		}

		//
		let gryphonAsts = swiftAsts.map {
			GRYSwift4_1Translator().translateAST($0)!
		}

		let equalGryphonAsts = swiftAsts.map {
			GRYSwift4_1Translator().translateAST($0)!
		}

		let differentGryphonAsts = equalGryphonAsts.rotated()

		// If the count is 1, rotating the array won't make it different
		XCTAssert(differentGryphonAsts.count > 1)

		for (ast1, ast2) in zip(gryphonAsts, equalGryphonAsts) {
			XCTAssert(ast1 == ast2)
		}

		for (ast1, ast2) in zip(gryphonAsts, differentGryphonAsts) {
			XCTAssert(ast1 != ast2)
		}
	}

	static var allTests = [
		("testTranslator", testTranslator),
		("testEquatable", testEquatable),
	]
}