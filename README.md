# JaSON
Dead simple and safe JSON value extraction

## Basic Usage

```Swift
var json: JSONObject = ["url": "http://apple.com", "foo": (2 as NSNumber), "str": "Hello, World!", "array": [1,2,3,4,7], "object": ["foo": (3 as NSNumber), "str": "Hello, World!"], "bool": (true as NSNumber), "urls": ["http://apple.com", "http://google.com"], "user": ["name": "Jason", "email": "email@email.com"], "users": [["name": "Jason", "email": "email@email.com"], ["name": "Bob", "email": "bob@email.com"]]]
do {
    var str: String = try json.valueForKey("str")
    var foo2: Int = try json.valueForKey("foo")
    var foo3: Int? = try json.valueForKey("foo")
    var foo4: Int? = try json.valueForKey("bar")
    var arr: [Int] = try json.valueForKey("array")
    var obj: JSONObject? = try json.valueForKey("object")
    let innerfoo: Int = try obj!.valueForKey("foo")
    let innerfoo2: Int = try json.valueForKey("object.foo")
    let bool: Bool = try json.valueForKey("bool")
    let url: NSURL = try json.valueForKey("url")
    let urls: [NSURL] = try json.valueForKey("urls")
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
        name = try json.valueForKey("name")
        email = try json.valueForKey("email")
    }
}

do {
    let user: User = try json.valueForKey("user")
    let users: [User] = try json.valueForKey("users")
}
catch {
    print("\(error)")
}
```
