# SPMLogger

SPMLogger is an iOS logger that you can use it for debug your app without using MacBook.
Is very easy to instantiate:

- import SPMLogger
- create an instance of LogView() 
- Use class Log for send log event to display


```swift
override func viewDidLoad() {
        super.viewDidLoad()
        let view = LogView()
        Log.e("Your Message")
}
```


## About Log class

Log is a singleton used for create a log to display. For use it just write __Log.__`
and the initial letter of our LogEvent.

ES.
```swift
Log.e("Your Message")
Log.i("Your Message")
Log.d("Your Message")
Log.v("Your Message")
Log.w("Your Message")
Log.s("Your Message")
```

```swift
internal enum LogEvent: String {
    case error = "[‼️]"
    case info = "[ℹ️]"
    case debug = "[💬]"
    case verbose = "[🔬]"
    case warning = "[⚠️]"
    case severe = "[🔥]"
}
```
