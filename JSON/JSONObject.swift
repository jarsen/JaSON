import Foundation

//
// MARK: - JSONError Type
//

public enum JSONError: ErrorType, CustomStringConvertible {
    case KeyNotFound(key: String)
    case NullValue(key: String)
    case TypeMismatch(expected: Any, actual: Any)
    case TypeMismatchWithKey(key: String, expected: Any, actual: Any)
    
    public var description: String {
        switch self {
        case let .KeyNotFound(key):
            return "Key not found: \(key)"
        case let .NullValue(key):
            return "Null Value found at: \(key)"
        case let .TypeMismatch(expected, actual):
            return "Type mismatch. Expected type \(expected). Got '\(actual)'"
        case let .TypeMismatchWithKey(key, expected, actual):
            return "Type mismatch. Expected type \(expected) at key: \(key). Got '\(actual)'"
        }
    }
}

//
// MARK: - JSONValue
//

public protocol JSONValue {
    typealias Value = Self
    
    static func JSONValue(object: Any) throws -> Value
}

extension JSONValue {
    public static func JSONValue(object: Any) throws -> Value {
        guard let objectValue = object as? Value else {
            throw JSONError.TypeMismatch(expected: Value.self, actual: object.dynamicType)
        }
        return objectValue
    }
}

//
// MARK: - JSONValue Implementations
//

extension String: JSONValue {}
extension Int: JSONValue {}
extension UInt: JSONValue {}
extension Float: JSONValue {}
extension Double: JSONValue {}
extension Bool: JSONValue {}

extension Array where Element: JSONValue {
    public static func JSONValue(object: Any) throws -> [Element] {
        guard let anyArray = object as? [AnyObject] else {
            throw JSONError.TypeMismatch(expected: self, actual: object.dynamicType)
        }
        return try anyArray.map { try Element.JSONValue($0) as! Element }
    }
}

extension Dictionary: JSONValue {
    public static func JSONValue(object: Any) throws -> [Key: Value] {
        guard let objectValue = object as? [Key: Value] else {
            throw JSONError.TypeMismatch(expected: self, actual: object.dynamicType)
        }
        return objectValue
    }
}

extension NSURL: JSONValue {
    public static func JSONValue(object: Any) throws -> NSURL {
        guard let urlString = object as? String, objectValue = NSURL(string: urlString) else {
            throw JSONError.TypeMismatch(expected: self, actual: object.dynamicType)
        }
        return objectValue
    }
}

extension JSONObject: JSONValue {
    public static func JSONValue(object: Any) throws -> JSONObject {
        guard let dictionary = object as? JSONDictionary else {
            throw JSONError.TypeMismatch(expected: self, actual: object.dynamicType)
        }
        
        return JSONObject(dictionary: dictionary)
    }
}

//
// MARK: - JSONObjectConvertible
//

public protocol JSONObjectConvertible : JSONValue {
    typealias ConvertibleType = Self
    init(json: JSONObject) throws
}

extension JSONObjectConvertible {
    public static func JSONValue(object: Any) throws -> ConvertibleType {
        guard let jsonDict = object as? JSONDictionary else {
            throw JSONError.TypeMismatch(expected: JSONDictionary.self, actual: object.dynamicType)
        }
        let json = JSONObject(dictionary: jsonDict)
        guard let value = try self.init(json: json) as? ConvertibleType else {
            throw JSONError.TypeMismatch(expected: ConvertibleType.self, actual: object.dynamicType)
        }
        return value
    }
}

//
// MARK: - JSONObjectDeconvertible
//

public protocol JSONDictionaryConvertible {
    var JSONDictionaryValue: JSONDictionary { get }
}

//
// MARK: - JSONObject
//

public typealias JSONDictionary = [String: AnyObject]

public struct JSONObject {
    public var dictionary: JSONDictionary
    
    public init?(data: NSData, options: NSJSONReadingOptions = []) throws {
        guard let dict = try NSJSONSerialization.JSONObjectWithData(data, options: options) as? JSONDictionary else {
            return nil
        }
        self.init(dictionary: dict)
    }
    
    public init(dictionary: JSONDictionary) {
        self.dictionary = dictionary
    }
    
    private func anyForKey(key: String) throws -> Any {
        let pathComponents = key.characters.split(".").map(String.init)
        var accumulator: Any = dictionary
        
        for component in pathComponents {
            if let componentData = accumulator as? JSONDictionary, value = componentData[component] {
                accumulator = value
                continue
            }
            
            throw JSONError.KeyNotFound(key: key)
        }
        
        if let _ = accumulator as? NSNull {
            throw JSONError.NullValue(key: key)
        }
        
        return accumulator
    }
    
    public func valueForKey<A: JSONValue>(key: String) throws -> A {
        let any = try anyForKey(key)
        guard let result = try A.JSONValue(any) as? A else {
            throw JSONError.TypeMismatchWithKey(key: key, expected: A.self, actual: any.dynamicType)
        }
        
        return result
    }
    
    public func valueForKey<A: JSONValue>(key: String) throws -> [A] {
        let any = try anyForKey(key)
        return try Array<A>.JSONValue(any)
    }
    
    public func valueForKey<A: JSONValue>(key: String) throws -> A? {
        do {
            return try self.valueForKey(key) as A
        }
        catch JSONError.KeyNotFound {
            return nil
        }
        catch JSONError.NullValue {
            return nil
        }
        catch {
            throw error
        }
    }
}

extension JSONObject: CustomStringConvertible {
    public var description: String {
        return dictionary.description
    }
}

extension JSONObject: CustomDebugStringConvertible {
    public var debugDescription: String {
        return dictionary.debugDescription
    }
}