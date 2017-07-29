@testable import Swasm

import XCTest

class WASMParserTests: XCTestCase {}

extension WASMParserTests {
	func testVector() {
		expect(WASMParser.vector(of: WASMParser.byte(0x01)), ByteStream(bytes: [0x01]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.vector(of: WASMParser.byte(0x01)), ByteStream(bytes: [0x00]),
		       toBe: ParserStreamError<ByteStream>.vectorInvalidLength(0, location: 0))

		expect(WASMParser.vector(of: WASMParser.byte(0x01)), ByteStream(bytes: [0x02, 0x01, 0x01]),
		       toBe: [0x01, 0x01])
	}

	func testByte() {
		expect(WASMParser.byte(0x01), ByteStream(bytes: [0x01]),
		       toBe: 0x01)

		expect(WASMParser.byte(0x01), ByteStream(bytes: []),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.byte(0x01), ByteStream(bytes: [0x02]),
		       toBe: ParserStreamError<ByteStream>.unexpected(0x02, location: 0))
	}

	func testByteInRange() {
		expect(WASMParser.byte(in: 0x01..<0x03), ByteStream(bytes: [0x02]),
		       toBe: 0x02)

		expect(WASMParser.byte(in: 0x01..<0x03), ByteStream(bytes: [0x02]),
		       toBe: 0x02)

		expect(WASMParser.byte(in: 0x01..<0x03), ByteStream(bytes: []),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.byte(in: 0x01..<0x03), ByteStream(bytes: [0x00]),
		       toBe: ParserStreamError<ByteStream>.unexpected(0x00, location: 0))
	}

	func testByteInSet() {
		expect(WASMParser.byte(in: Set([0x01, 0x02, 0x03])), ByteStream(bytes: [0x02]),
		       toBe: 0x02)

		expect(WASMParser.byte(in: Set([0x01, 0x02, 0x03])), ByteStream(bytes: []),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.byte(in: Set([0x01, 0x02, 0x03])), ByteStream(bytes: [0x00]),
		       toBe: ParserStreamError<ByteStream>.unexpected(0x00, location: 0))
	}

	func testBytes() {
		expect(WASMParser.bytes([0x01, 0x02, 0x03]), ByteStream(bytes: [0x01]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.bytes([0x01, 0x02, 0x03]), ByteStream(bytes: [0x01, 0x02, 0x03]),
		       toBe: [0x01, 0x02, 0x03])

		expect(WASMParser.bytes([0x01, 0x02, 0x03]), ByteStream(bytes: [0x01, 0x09]),
		       toBe: ParserStreamError<ByteStream>.unexpected(0x09, location: 1))
	}
}

extension WASMParserTests {
	func testUInt() {
		expect(WASMParser.uint(8), ByteStream(bytes: [0b01111111]),
		       toBe: 0b01111111)

		expect(WASMParser.uint(8), ByteStream(bytes: [0b10000000]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.uint(8), ByteStream(bytes: [0b10000000, 0b10000000]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.uint(1), ByteStream(bytes: [0b10000000, 0b10000000]),
		       toBe: ParserStreamError<ByteStream>.unexpected(0b10000000, location: 0))

		expect(WASMParser.uint(8), ByteStream(bytes: [0b10000010, 0b00000001]),
		       toBe: 0b0000001_0000010)

		expect(WASMParser.uint(8), ByteStream(bytes: [0b10000011, 0b10000010, 0b00000001]),
		       toBe: 0b0000001_0000010_0000011)
	}

	func testSInt() {
		expect(WASMParser.sint(8), ByteStream(bytes: [0b01000001]),
		       toBe: -0b00111111)

		expect(WASMParser.sint(8), ByteStream(bytes: [0b10000000]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.sint(8), ByteStream(bytes: [0b10000000, 0b10000000]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.sint(1), ByteStream(bytes: [0b10000000, 0b10000000]),
		       toBe: ParserStreamError<ByteStream>.unexpected(0b10000000, location: 0))

		expect(WASMParser.sint(8), ByteStream(bytes: [0b10000000, 0b00000001]),
		       toBe: 0b10000000)

		expect(WASMParser.sint(8), ByteStream(bytes: [0b11000010, 0b11000001, 0b01000000]),
		       toBe: -0b0111111_0111110_0111110)
	}

	func testInt() {
		expect(WASMParser.int(8), ByteStream(bytes: [0b01000001]),
		       toBe: -0b00111111)

		expect(WASMParser.int(8), ByteStream(bytes: [0b10000000]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.int(8), ByteStream(bytes: [0b10000000, 0b10000000]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.int(1), ByteStream(bytes: [0b10000000, 0b10000000]),
		       toBe: ParserStreamError<ByteStream>.unexpected(0b10000000, location: 0))

		expect(WASMParser.int(8), ByteStream(bytes: [0b10000000, 0b00000001]),
		       toBe: -0b10000000)

		expect(WASMParser.int(8), ByteStream(bytes: [0b11000010, 0b11000001, 0b01000000]),
		       toBe: -0b0111111_0111110_0111110)
	}
}

extension WASMParserTests {
	func testFloat32() {
		expect(WASMParser.float32(), ByteStream(bytes: [0b11111111, 0b11111111]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.float32(), ByteStream(bytes: [0b00111111, 0b10000000, 0b00000000, 0b00000000]),
		       toBe: 1.0)

		expect(WASMParser.float32(), ByteStream(bytes: [0b01000000, 0b01001001, 0b00001111, 0b11011010]),
		       toBe: .pi)
	}

	func testFloat64() {
		expect(WASMParser.float64(), ByteStream(bytes: [
			0b11111111, 0b11111111, 0b11111111, 0b11111111,
			]), toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.float64(), ByteStream(bytes: [
			0b00111111, 0b11110000, 0b00000000, 0b00000000,
			0b00000000, 0b00000000, 0b00000000, 0b00000000,
			]), toBe: 1.0)

		expect(WASMParser.float64(), ByteStream(bytes: [
			0b01000000, 0b00001001, 0b00100001, 0b11111011,
			0b01010100, 0b01000100, 0b00101101, 0b00011000,
			]), toBe: .pi)
	}
}

extension WASMParserTests {
	func testUnicode() {
		expect(WASMParser.name(), ByteStream(bytes: [0x01, 0x61]),
		       toBe: "a")

		expect(WASMParser.name(), ByteStream(bytes: [0x01]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.name(), ByteStream(bytes: [0x02, 0xC3, 0xA6]),
		       toBe: "æ")

		expect(WASMParser.name(), ByteStream(bytes: [0x02, 0xC3]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.name(), ByteStream(bytes: [0x03, 0xE3, 0x81, 0x82]),
		       toBe: "あ")

		expect(WASMParser.name(), ByteStream(bytes: [0x03, 0xE3, 0x81]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.name(), ByteStream(bytes: [0x04, 0xF0, 0x9F, 0x8D, 0xA3]),
		       toBe: "🍣")

		expect(WASMParser.name(), ByteStream(bytes: [0x04, 0xF0, 0x9F, 0x8D]),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)
	}

	func testName() {
		expect(WASMParser.name(), ByteStream(bytes: [0x03, 0xE3, 0x81, 0x82]),
		       toBe: "あ")
	}
}

extension WASMParserTests {
	func testValueType() {
		expect(WASMParser.valueType(), ByteStream(bytes: []),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.valueType(), ByteStream(bytes: [0x7F]),
		       toBe: .int32)

		expect(WASMParser.valueType(), ByteStream(bytes: [0x7E]),
		       toBe: .int64)

		expect(WASMParser.valueType(), ByteStream(bytes: [0x7D]),
		       toBe: .uint32)

		expect(WASMParser.valueType(), ByteStream(bytes: [0x7C]),
		       toBe: .uint64)

		expect(WASMParser.valueType(), ByteStream(bytes: [0x7B]),
		       toBe: ParserStreamError<ByteStream>.unexpected(0x7B, location: 0))
	}

	func testResultType() {
		expect(WASMParser.resultType(), ByteStream(bytes: []),
		       toBe: ParserStreamError<ByteStream>.unexpectedEnd)

		expect(WASMParser.resultType(), ByteStream(bytes: [0x40]),
		       toBe: [])

		expect(WASMParser.resultType(), ByteStream(bytes: [0x7F]),
		       toBe: [.int32])

		expect(WASMParser.resultType(), ByteStream(bytes: [0x7E]),
		       toBe: [.int64])

		expect(WASMParser.resultType(), ByteStream(bytes: [0x7D]),
		       toBe: [.uint32])

		expect(WASMParser.resultType(), ByteStream(bytes: [0x7C]),
		       toBe: [.uint64])

		expect(WASMParser.resultType(), ByteStream(bytes: [0x7B]),
		       toBe: ParserStreamError<ByteStream>.unexpected(0x7B, location: 0))
	}

	func testFunctionType() {
		expect(WASMParser.functionType(), ByteStream(bytes: [0x60, 0x01, 0x7E, 0x01, 0x7D]),
		       toBe: FunctionType(parameters: [.int64], results: [.uint32]))
	}

	func testLimits() {
		expect(WASMParser.limits(), ByteStream(bytes: [0x00, 0x01]),
		       toBe: Limits(min: 1, max: nil))

		expect(WASMParser.limits(), ByteStream(bytes: [0x01, 0x01, 0x02]),
		       toBe: Limits(min: 1, max: 0x02))
	}

	func testMemoryType() {
		expect(WASMParser.memoryType(), ByteStream(bytes: [0x00, 0x01]),
		       toBe: MemoryType(min: 1, max: nil))

		expect(WASMParser.memoryType(), ByteStream(bytes: [0x01, 0x01, 0x02]),
		       toBe: MemoryType(min: 1, max: 0x02))
	}

	func testTableType() {
		expect(WASMParser.tableType(), ByteStream(bytes: [0x70, 0x00, 0x01]),
		       toBe: TableType(limits: Limits(min: 1, max: nil)))

		expect(WASMParser.tableType(), ByteStream(bytes: [0x70, 0x01, 0x01, 0x02]),
		       toBe: TableType(limits: Limits(min: 1, max: 0x02)))
	}

	func testGlobalType() {
		expect(WASMParser.globalType(), ByteStream(bytes: [0x7F, 0x00]),
		       toBe: GlobalType(mutability: .constant, valueType: .int32))

		expect(WASMParser.globalType(), ByteStream(bytes: [0x7F, 0x01]),
		       toBe: GlobalType(mutability: .variable, valueType: .int32))
	}

	func testIndex() {
		expect(WASMParser.index(), ByteStream(bytes: [0x7F]),
		       toBe: 0x7F)
	}
}