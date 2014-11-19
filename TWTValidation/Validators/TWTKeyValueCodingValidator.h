//
//  TWTKeyValueCodingValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 4/21/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <TWTValidation/TWTValidator.h>

/*! 
 TWTKeyValueCodingValidators validate the values for a subset of an object’s key-value coding compliant keys. 
 This subset of keys is called the validator’s key set. When validating an object O, the validator iterates 
 over each key K in its key set and asks O for the set of validators to use to validate K’s corresponding value.
 It does this in a three-stage process. First, it sends O the -twt_validatorsForKey: message. If O responds with
 a set of validators, those are used to validate K’s corresponding value. If it responds with nil, the validator
 will send the +twt_validatorsForKey: message to O’s class. If this returns a non-nil set of validators, those 
 are used to perform validation. Otherwise, the validator validates the value using O’s implementation of 
 -validateValue:forKey:error:. This is repeated for each key in the validator’s key set. An object is considered
 valid only if all validations pass.

 Values that are nil or the NSNull instance do not pass validation with key-value coding validators.

 Key-Value Coding validators are immutable objects. As such, sending -copy or -copyWithZone: to a key-value 
 coding validator will simply return the validator itself.
 */
@interface TWTKeyValueCodingValidator : TWTValidator <NSCopying>

/*! The set of KVC keys whose values the instance validates. */
@property (nonatomic, copy, readonly) NSSet *keys;

/*!
 @abstract Initializes a newly created TWTKeyValueCodingValidator instance with the specified set of keys.
 @discussion This is the designated initializer.
 @param keys A set of key-value coding keys. Values validated by this class must be key-value coding compliant
     for the specified key set, or else an error will occur during validation.
 @result A newly initialized key-value coding validator with the specified set of keys.
 */
- (instancetype)initWithKeys:(NSSet *)keys;

@end


/*!
 The TWTKeyValueCodingValidator category on NSObject declares two methods, -twt_validatorsForKey: and
 +twt_validatorsForKey:, which TWTKeyValueCodingValidator instances use to get the validators for an object’s
 KVC-compliant keys.
 
 Typically, instead of overriding -twt_validatorsForKey: and +twt_validatorsForKey:, subclasses should implement
 -twt_validatorsFor«Key» or +twt_validatorsFor«Key», with «Key» being the capitalized form of the KVC key. The
 base implementations of -twt_validatorsForKey: and +twt_validatorsForKey: simply check to see the receiver 
 responds to the key-specific form of the message, and if so, return the value of that.
 
 -twt_validatorsForKey: is meant to return validators that depend on the runtime state of an object. If your
 object’s validators are static, it is better ot use +twt_validatorsForKey:, as these validators can be cached
 by the validation system. You can, of course, use a combination of the two methods if some of your keys have
 static validators while others depend on runtime state. Note however that if -twt_validatorsForKey: returns
 a non-nil object for a given key, +twt_validatorsForKey: will not be invoked for the same key.
 */
@interface NSObject (TWTKeyValueCodingValidator)

/*!
 @abstract Returns the validators that should be used for the specified KVC key.
 @discussion Classes should override this method (or implement +twt_validatorsFor«Key») to return validators
     that do not depend on runtime state. If you have validators that depend on the runtime state of an object,
     implement the instance version of this method.

     The base implementation checks if the receiver responds to +twt_validatorsFor«Key», and if so, returns
     the result of sending the receiver that message. Subclass implementations should take care to invoke
     their superclass’s implementation to retain this behavior.
 @param key A key for which instances of the receiver are key-value coding compliant.
 @result A set of validators that should be used to validate the value for the specified KVC key.
 */
+ (NSSet *)twt_validatorsForKey:(NSString *)key;

/*!
 @abstract Returns the validators that should be used for the specified KVC key.
 @discussion Classes should override this method (or implement -twt_validatorsFor«Key») to return validators
     that depend on runtime state. If you have validators that do not depend on the runtime state of an object,
     implement the class version of this method.

     The base implementation checks if the receiver responds to -twt_validatorsFor«Key», and if so, returns
     the result of sending the receiver that message. Subclass implementations should take care to invoke
     their superclass’s implementation to retain this behavior.
 @param key A key for which instances of the receiver are key-value coding compliant.
 @result A set of validators that should be used to validate the value for the specified KVC key.
 */
- (NSSet *)twt_validatorsForKey:(NSString *)key;

@end
