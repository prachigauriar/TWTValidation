# TWTValidation

TWTValidation is a Cocoa framework for declaratively validating data. It provides a mechanism for
validating individual objects and collections, and for combining multiple validators using logical
operators to create more complex validations.


## Features

* Simple, well-documented, and well-tested Objective-C API
* Flexible system for validating objects that makes few assumptions about your model classes
* Strong error reporting to help you understand which validators failed and why
* Built-in validators for validating numbers and strings
* Collection validators to validate a collection’s count and elements
* Keyed collection validators to validate a keyed collection’s count, keys, values, and specific
  key-value pairs
* Compound validators that combine validators using logical operations like AND, OR, and NOT.
* Block validators to easily create validators with custom logic
* An easy-to-extend API for creating your own reusable validators
* Works with both iOS and OS X


## Installation

The easiest way to start using TWTValidation is to install it with CocoaPods.

    pod 'TWTValidation', '~> 1.0'

You can also build it and include the built products in your project. For OS X, just add `TWTValidation.framework` to your project. For iOS, add TWTValidation’s public headers to your header search path and link in `libTWTValidation.a`, all of which can be found in the project’s build output directory.


## Using TWTValidation




