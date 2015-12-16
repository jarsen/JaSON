# JaSON
Dead simple and safe JSON value extraction

## Basic Usage

```Swift
var json: JSONObject = ["url": "http://apple.com", "foo": (2 as NSNumber), "str": "Hello, World!", "array": [1,2,3,4,7], "object": ["foo": (3 as NSNumber), "str": "Hello, World!"], "bool": (true as NSNumber), "urls": ["http://apple.com", "http://google.com"], "user": ["name": "Jason", "email": "email@email.com"], "users": [["name": "Jason", "email": "email@email.com"], ["name": "Bob", "email": "bob@email.com"]]]
do {
    var str: String = try json.JSONValueForKey("str")
    var foo2: Int = try json.JSONValueForKey("foo")
    var foo3: Int? = try json.JSONValueForKey("foo")
    var foo4: Int? = try json.JSONValueForKey("bar")
    var arr: [Int] = try json.JSONValueForKey("array")
    var obj: JSONObject? = try json.JSONValueForKey("object")
    let innerfoo: Int = try obj!.JSONValueForKey("foo")
    let innerfoo2: Int = try json.JSONValueForKey("object.foo")
    let bool: Bool = try json.JSONValueForKey("bool")
    let url: NSURL = try json.JSONValueForKey("url")
    let urls: [NSURL] = try json.JSONValueForKey("urls")
}
catch {
    print("\(error)")
}
```

## Resources

Check out my series of articles on JSON value extraction at [my blog](http://jasonlarsen.me/2015/10/16/no-magic-json-pt3.html)

And don't forget if you don't like `do/catch` you can always use `try?`... but you will lose error information.

## Init Your Own Custom Classes

Want to init your own classes from `JSONObject`s or arrays of `JSONObject`?

```Swift
struct User : JSONObjectConvertible {
    let name: String
    let email: String
    
    init(json: JSONObject) throws {
        name = try json.JSONValueForKey("name")
        email = try json.JSONValueForKey("email")
    }
}

do {
    let user: User = try json.JSONValueForKey("user")
    let users: [User] = try json.JSONValueForKey("users")
}
catch {
    print("\(error)")
}
```
