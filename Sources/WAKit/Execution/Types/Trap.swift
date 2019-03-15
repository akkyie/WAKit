public enum Trap: Error {
    // FIXME: for debugging purposes, to be eventually deleted
    case _raw(String)
    case _unimplemented(description: String, file: StaticString, line: UInt)

    case unreachable

    // Stack
    case stackTypeMismatch(expected: Any.Type, actual: Any.Type)
    case stackValueTypesMismatch(expected: ValueType, actual: [Any.Type])
    case stackNotFound(Any.Type, index: Int)
    case localIndexOutOfRange(index: UInt32)

    // Store
    case globalIndexOutOfRange(index: UInt32)
    case globalImmutable(index: UInt32)

    // Instruction
    case invalidTypeForInstruction(Any.Type, Instruction)

    static func unimplemented(_ description: String = "", file: StaticString = #file, line: UInt = #line) -> Trap {
        return ._unimplemented(description: description, file: file, line: line)
    }
}