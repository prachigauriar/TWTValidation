# TWTValidation

TWTValidation is a Cocoa framework for declaratively validating data. It provides a mechanism for
validating individual objects and collections, and for combining multiple validators using logical
operators to create more complex validations.


## Features

* Simple, well-documented, and well-tested Objective-C API
* Flexible system for validating objects that makes few assumptions about your model classes
* Strong error reporting to help you understand which validators failed and why
* Built-in validators for validating numbers and strings
* Block validators to easily create validators with custom logic
* Compound validators that combine validators using logical operations like AND, OR, and NOT.
* Collection validators to validate a collection’s count and elements
* Keyed collection validators to validate a keyed collection’s count, keys, values, and specific
  key-value pairs
* Key-Value Coding validators to validate an object’s keys and values using validators defined
  by the object’s class
* An easy-to-extend API for creating your own reusable validators
* Works with both iOS and OS X


## Installation

The easiest way to start using TWTValidation is to install it with CocoaPods.

    pod 'TWTValidation', '~> 1.0'

You can also build it and include the built products in your project. For OS X, just add
`TWTValidation.framework` to your project. For iOS, add TWTValidation’s public headers to your
header search path and link in `libTWTValidation.a`, all of which can be found in the project’s
build output directory.


## Using TWTValidation

TWTValidation provides validators for a variety of use cases, but doesn’t constrain how you use
them. All validators in TWTValidation inherit from `TWTValidator`, an abstract class that declares
the primary interface to a validator, `-validateValue:error:`. This method validates the specified
value and returns whether it passed validation. If the value failed to validate, an error describing
why validation failed is returned indirectly via the error parameter.

Let’s step through each of the major subclasses of `TWTValidator` in turn. These are merely
summaries of what’s possible. For more detailed information, check out the documentation in each
class’s header.


### Value Validators

Value validators inherit from `TWTValueValidator`. By itself, `TWTValueValidator` can only perform
some basic validations: it can optionally ensure that a value is an instance of a specific class,
not `nil`, and not the `NSNull` instance.

    TWTValueValidator *validator = [TWTValueValidator valueValidatorWithClass:[NSNumber class]     
                                                                    allowsNil:NO 
                                                                   allowsNull:YES];

    NSError *error = nil;
    [validator validateValue:@10 error:&error];             // Returns YES
    [validator validateValue:[NSNull null] error:&error];   // Returns YES
    [validator validateValue:@"foo" error:&error];          // Returns NO
    [validator validateValue:nil error:&error];             // Returns NO
    
More useful validations are performed by `TWTValueValidator`’s subclasses, `TWTStringValidator` and 
`TWTNumberValidator`. String validators can validate that a value is a string and either matches a 
specified regular expression or has a length within a specified range:

    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:@"^[A-Z][a-z]+$"
                                                                      options:0
                                                                        error:NULL];

    NSError *error = nil;
    TWTStringValidator *validator = [TWTStringValidator stringValidatorWithRegularExpression:regEx 
                                                                                     options:0];
    [validator validateValue:@"Uppercase" error:&error];    // Returns YES
    [validator validateValue:@"lowercase" error:&error];    // Returns NO

    validator = [TWTStringValidator stringValidatorWithMinimumLength:4 maximumLength:10];
    [validator validateValue:@"Foobar" error:&error];       // Returns YES
    [validator validateValue:@"Foo" error:&error];          // Returns NO
    
Number validators ensure that a number is within a specified range and optionally has no fractional
part.

    TWTNumberValidator *validator = [[TWTNumberValidator alloc] initWithMinimum:@10 maximum:@20];
    
    NSError *error = nil;
    [validator validateValue:@15.333 error:&error];         // Returns YES
    [validator validateValue:@3 error:&error];              // Returns NO

    validator.requiresIntegralValue = YES;
    [validator validateValue:@15.333 error:&error];         // Returns NO


### Compound Validators

Instances of `TWTCompoundValidator`, or simply compound validators, allow you to combine validators
using logical operations like AND, OR, and NOT.

    TWTNumberValidator *rangeValidator = [TWTNumberValidator numberValidatorWithMinimum:@2 maximum:@10];
    TWTCompoundValidator *notValidator = [TWTCompoundValidator notValidatorWithSubvalidator:rangeValidator];
    
    NSError *error = nil;
    [notValidator validateValue:@3 error:&error];           // Returns NO
    [notValidator validateValue:@0.123 error:&error];       // Returns YES
    [notValidator validateValue:@"foo" error:&error];       // Returns YES, :-(
    
    TWTNumberValidator *numberValidator = [[TWTNumberValidator alloc] init];
    NSArray *subvalidators = @[ numberValidator, notValidator ];
    TWTCompoundValidator *andValidator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];

    [andValidator validateValue:@3 error:&error];           // Returns NO
    [andValidator validateValue:@0.123 error:&error];       // Returns YES
    [andValidator validateValue:@"foo" error:&error];       // Returns NO, :-)

    TWTNumberValidator *integralValidator = [rangeValidator copy];
    integralValidator.requiresIntegralValue = YES;
    subvalidators = @[ andValidator, integralValidator ];
    TWTCompoundValidator *orValidator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    
    [orValidator validateValue:@3 error:&error];            // Returns YES
    [orValidator validateValue:@7.33 error:&error];         // Returns NO
    [orValidator validateValue:@0 error:&error];            // Returns YES
    [orValidator validateValue:@"foo" error:&error];        // Returns NO


### Block Validators

`TWTBlockValidator`s allow you to specify a block to perform arbitrary validations.

    NSSet *allowedValues = [NSSet setWithObjects:@"value1", @"value2", @"value3", nil];

    TWTBlockValidator *validator = [[TWTBlockValidator alloc] initWithBlock:^BOOL(id value, NSError **error) {
        BOOL validated = [allowedValues containsObject:value];
        if (!validated && error) {
            *error = [NSError twt_validationErrorWithCode:5 
                                                    value:value 
                                     localizedDescription:NSLocalizedString(@"Value is not in set", nil)];
        }
        
        return validated;
    }];

    NSError *error = nil;
    [validator validateValue:@"value1" error:&error];       // Returns YES
    [validator validateValue:@"value4" error:&error];       // Returns NO


### Collection Validators

You can validate a collection’s count and elements using an instance of `TWTCollectionValidator`. 
Collection validators use fast enumeration to get a collection’s elements. As such, it is primarily
intended for validating arrays, sets, and ordered sets. However, it can work with any object that
implements `NSFastEnumeration` and responds to `-count`.

    TWTNumberValidator *countValidator = [[TWTNumberValidator alloc] initWithMinimum:@1 maximum:@3];

    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:@"^[A-Z][a-z]+$"
                                                                      options:0
                                                                        error:NULL];
    NSArray *elementValidators = @[ [TWTStringValidator stringValidatorWithRegularExpression:regEx 
                                                                                     options:0] ];
    
    TWTCollectionValidator *validator = 
            [[TWTCollectionValidator alloc] initWithCountValidator:countValidator
                                                 elementValidators:elementValidators];

    NSError *error = nil;
    id collection = [NSSet setWithObjects:@"Apple", @"Pear", @"Orange", nil];
    [validator validateValue:collection error:&error];      // Returns YES

    collection = @[ @"Apple", @"Pear", @"orange" ];
    [validator validateValue:collection error:&error];      // Returns NO

    collection = [NSOrderedSet orderedSetWithObjects:@"Apple", @"Pear", @"Orange", @"Grape", nil];
    [validator validateValue:collection error:&error];      // Returns NO


### Keyed Collection Validators

To validate dictionaries and map tables, use `TWTKeyedCollectionValidator`s. These validator can 
validate a keyed collection’s count, keys, and values, as well as specific key-value pairs.

    TWTNumberValidator *countValidator = [[TWTNumberValidator alloc] initWithMinimum:@1 maximum:@3];
    TWTStringValidator *keyValidator = [[TWTStringValidator alloc] init];
    TWTStringValidator *valueValidator = [[TWTNumberValidator alloc] init];
    
    TWTNumberValidator *ageValidator = [[TWTNumberValidator alloc] initWithMinimum:@0 maximum:@130];
    TWTKeyValuePairValidator *agePairValidator = [[TWTKeyValuePairValidator alloc] initWithKey:@"age"
                                                                                valueValidator:ageValidator]
    
    TWTKeyedCollectionValidator *validator = 
            [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                          keyValidators:@[ keyValidator ]
                                                        valueValidators:@[ valueValidator ]
                                                 keyValuePairValidators:@[ agePairValidator ]];
    
    NSError *error = nil;
    id collection = @{ @"key1" : @1 };
    [validator validateValue:collection error:&error];      // Returns YES

    collection = @{ @"key1" : @1, @"key2" : @2, @"key3" : @3, @"key4" : @4 };
    [validator validateValue:collection error:&error];      // Returns NO

    collection = @{ @1 : @2 };
    [validator validateValue:collection error:&error];      // Returns NO

    collection = @{ @"key1" : @"value1" };
    [validator validateValue:collection error:&error];      // Returns NO

    collection = @{ @"key1" : @1, @"key2" : @2, @"age" : @11 };
    [validator validateValue:collection error:&error];      // Returns YES

    collection = @{ @"key1" : @1, @"key2" : @2, @"age" : @-3 };
    [validator validateValue:collection error:&error];      // Returns NO


### Key-Value Coding Validators

Perhaps the most interesting and useful validators in TWTValidation are key-value coding validators.
These objects—instances of `TWTKeyValueCodingValidator`—validate an object’s values for a given set
of key-value coding compliant keys. It gets the validators to use for each key from the object’s
class. This is best explained using an example:

    // Header File
    @interface TWTSimplePerson : NSObject
    
    @property (nonatomic, copy) NSString *firstName;
    @property (nonatomic, copy) NSString *lastName;
    @property (nonatomic, strong) NSNumber *age;

    - (BOOL)isValid;

    @end


    // Implementation File
    #import <TWTValidation/TWTValidation.h>

    @interface TWTSimplePerson ()
    @property (nonatomic, strong) TWTKeyValueCodingValidator *validator;
    @end


    @implementation TWTSimplePerson

    - (instancetype)init
    {
        self = [super init];
        if (self) {
            NSSet *keys = [NSSet setWithObjects:@"firstName", @"lastName", @"age", nil];
            _validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:keys];
        }
        
        return self;
    }

    
    - (BOOL)isValid
    {
        return [self.validator validateValue:self error:NULL];
    }


    // Key-value coding validators get the validators for their KVC keys by invoking +twt_validatorsForKey:
    // on the value’s class. The base implementation simply checks to see if the class implements 
    // +twt_validatorsFor«Key», where «Key» is the capitalized form of the KVC key. When you have multiple
    // keys that use the same validators, you can override this implementation. Here, we return the same
    // validators for firstName and lastName, but rely on the superclass implementation to invoke 
    // +twt_validatorsForAge to get the validators for the age key.

    + (NSSet *)twt_validatorsForKey:(NSString *)key
    {
        if ([key isEqualToString:@"firstName"] || [key isEqualToString:@"lastName"]) {
            return [NSSet setWithObject:[TWTStringValidator stringValidatorWithMinimumLength:1 maximumLength:20]];        
        } 
            
        return [super twt_validatorsForKey:key];
    }

    
    + (NSSet *)twt_validatorsForAge
    {
        return [NSSet setWithObject:[[TWTNumberValidator alloc] initWithMinimum:@0 maximum:@130]];
    }
    
    @end


### Creating Custom Validators

If one of TWTValidation’s validators doesn’t meet your needs, it’s easy to add new validators or
extend existing ones. Simply subclass `TWTValidator` or one of its subclasses and override
`-validateValue:error:`. Take a look at any `TWTValidator` subclass for more guidance. We also
provide some convenience methods for building error objects, which can be found in
`TWTValidationErrors.h`.


## Contributing, Filing Bugs, and Requesting Enhancements

If you would like to help fix bugs or add features to TWTValidation, send us a pull request!

We use GitHub issues for bugs, enhancement requests, and the limited support we provide, so open an
issue for any of those.


## License

All code is licensed under the MIT license. Do with it as you will.
