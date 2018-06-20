# DSLabel.swift

DSLabel inherits from UILabel in order to support tappable texts and so create links

## Features

* Swift 4
* You can indicate which substring is tappable
* If desired substring appears multiple times, you can make all of them tappable or choose which of them is really tappable
* You can change the font and color of tappable texts
* Works as a UILabel
* Simply drag and drop DSLabel.swift into your project
* Easily you can increase line spacing

## Usage

```swift
let label = DSLabel()
label.lineBreakMode = .byWordWrapping
label.numberOfLines = 0
label.text = "By signing up, I accept Terms and Conditions and the Privacy Policy."
label.lineSpacing = 2
label.addLink(text: "Terms and Conditions")
label.addLink(text: "Privacy Policy")
label.linkFont = UIFont.boldSystemFont(ofSize: 11)
label.linkColor = UIColor.red
label.handleLink { (text, range) in
	if text == "Terms and Conditions" {
		// Do what you want if user taps over "Terms and Conditions" text
	}
	if text == "Privacy Policy" {
		// Do what you want if user taps over "Privacy Policy" text
	}
}
```

## Install

Simply drag and drop DSLabel.swift into your project
