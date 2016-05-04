# RxPasscode
This simple project will display an iOS style passcode screen. There are many passcode projects out there, but I wanted to write my own to: 

1. Learn Functional reactive programming
2. Be maintainable peice of code, many other libraries are old and lots more lines of code
3. To install, run `pod install` and open the app
4. Does not include Touch ID support
4. Default passcode is 1234

The Passcode presentation has 3 scenarios:

1. Validate passcode
1. Set new passcode
1. Change existing passcode (Which amounts to Validate => Set new)


**RxSwift**: The reactive programming library: https://github.com/ReactiveX/RxSwift  

![Imgur](http://i.imgur.com/gQ1O2XB.png)
