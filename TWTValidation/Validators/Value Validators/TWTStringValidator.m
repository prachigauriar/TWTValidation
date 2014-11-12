//
//  TWTStringValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/27/2014.
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

#import <TWTValidation/TWTStringValidator.h>

#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>


@interface TWTBoundedLengthStringValidator ()

@property (nonatomic, assign, readwrite) NSUInteger minimumLength;
@property (nonatomic, assign, readwrite) NSUInteger maximumLength;

@end


#pragma mark

@interface TWTRegularExpressionStringValidator ()

@property (nonatomic, strong, readwrite) NSRegularExpression *regularExpression;
@property (nonatomic, assign, readwrite) NSMatchingOptions options;

@end

#pragma mark

@interface TWTPrefixStringValidator ()

@property (nonatomic, copy, readwrite) NSString *prefix;
@property (nonatomic, assign, readwrite) BOOL validatesCase;

@end

#pragma mark

@interface TWTSuffixStringValidator ()

@property (nonatomic, copy, readwrite) NSString *suffix;
@property (nonatomic, assign, readwrite) BOOL validatesCase;

@end


#pragma mark

@interface TWTSubstringValidator ()

@property (nonatomic, copy, readwrite) NSString *substring;
@property (nonatomic, assign, readwrite) BOOL validatesCase;

@end


#pragma mark

@interface TWTWildcardMatchingStringValidatator ()

@property (nonatomic, copy) NSString *matchingString;
@property (nonatomic, copy) NSString *predicateFormat;
@property (nonatomic, assign, readwrite) BOOL validatesCase;

@end


#pragma mark

@implementation TWTStringValidator

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.valueClass = [NSString class];
    }

    return self;
}


+ (TWTBoundedLengthStringValidator *)stringValidatorWithLength:(NSUInteger)length
{
    return [[TWTBoundedLengthStringValidator alloc] initWithMinimumLength:length maximumLength:length];
}


+ (TWTBoundedLengthStringValidator *)stringValidatorWithMinimumLength:(NSUInteger)minimumLength maximumLength:(NSUInteger)maximumLength
{
    return [[TWTBoundedLengthStringValidator alloc] initWithMinimumLength:minimumLength maximumLength:maximumLength];
}


+ (TWTRegularExpressionStringValidator *)stringValidatorWithRegularExpression:(NSRegularExpression *)regularExpression options:(NSMatchingOptions)options
{
    return [[TWTRegularExpressionStringValidator alloc] initWithRegularExpression:regularExpression options:options];
}


+ (TWTPrefixStringValidator *)stringValidatorWithPrefixString:(NSString *)prefixString caseSensitive:(BOOL)caseSensitve
{
    return [[TWTPrefixStringValidator alloc] initWithPrefixString:prefixString caseSensitive:caseSensitve];
}


+ (TWTSuffixStringValidator *)stringValidatorWithSuffixString:(NSString *)suffixString caseSensitive:(BOOL)caseSensitive
{
    return [[TWTSuffixStringValidator alloc] initWithSuffixString:suffixString caseSensitive:caseSensitive];
}


+ (TWTSubstringValidator *)stringValidatorWithSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive
{
    return [[TWTSubstringValidator alloc] initWithSubstring:substring caseSensitive:caseSensitive];
}


+ (TWTWildcardMatchingStringValidatator *)stringValidatorWithMatchingString:(NSString *)matchingString caseSensitive:(BOOL)caseSensitive
{
    return [[TWTWildcardMatchingStringValidatator alloc] initWithMatchingString:matchingString caseSensitive:caseSensitive];
}

@end


#pragma mark

@implementation TWTBoundedLengthStringValidator

- (instancetype)init
{
    return [self initWithMinimumLength:0 maximumLength:NSUIntegerMax];
}


- (instancetype)initWithMinimumLength:(NSUInteger)minimumLength maximumLength:(NSUInteger)maximumLength
{
    NSParameterAssert(minimumLength <= maximumLength);
    self = [super init];
    if (self) {
        _minimumLength = minimumLength;
        _maximumLength = maximumLength;
    }

    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.minimumLength = self.minimumLength;
    copy.maximumLength = self.maximumLength;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.minimumLength ^ self.maximumLength;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return other.minimumLength == self.minimumLength && other.maximumLength == self.maximumLength;
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value)) {
        // This will only happen if nil or null is allowed
        return YES;
    }

    NSInteger errorCode = -1;

    if ([value length] < self.minimumLength) {
        errorCode = TWTValidationErrorCodeLengthLessThanMinimum;
    } else if ([value length] > self.maximumLength) {
        errorCode = TWTValidationErrorCodeLengthGreaterThanMaximum;
    } else {
        return YES;
    }

    if (outError) {
        NSString *description = nil;
        switch (errorCode) {
            case TWTValidationErrorCodeLengthLessThanMinimum: {
                NSString *descriptionFormat = TWTLocalizedString(@"TWTBoundedLengthStringValidator.lengthLessThanMinimum.validationError.format");
                description = [NSString stringWithFormat:descriptionFormat, (unsigned long)[value length], (unsigned long)self.minimumLength];
                break;
            }
            case TWTValidationErrorCodeLengthGreaterThanMaximum: {
                NSString *descriptionFormat = TWTLocalizedString(@"TWTBoundedLengthStringValidator.lengthGreaterThanMaximum.validationError.format");
                description = [NSString stringWithFormat:descriptionFormat, (unsigned long)[value length], (unsigned long)self.minimumLength];
                break;
            }
        }

        *outError = [NSError twt_validationErrorWithCode:errorCode failingValidator:self value:value localizedDescription:description];
    }
    
    return NO;
}

@end


#pragma mark

@implementation TWTRegularExpressionStringValidator

- (instancetype)init
{
    return [self initWithRegularExpression:nil options:0];
}


- (instancetype)initWithRegularExpression:(NSRegularExpression *)regularExpression options:(NSMatchingOptions)options
{
    self = [super init];
    if (self) {
        _regularExpression = regularExpression;
        _options = options;
    }

    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.regularExpression = self.regularExpression;
    copy.options = self.options;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.regularExpression.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    typeof(self) other = object;

    return self.options == other.options && (other.regularExpression == self.regularExpression || [other.regularExpression isEqual:self.regularExpression]);
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value) || !self.regularExpression ||
               [self.regularExpression numberOfMatchesInString:value options:self.options range:NSMakeRange(0, [value length])]) {
        // If nil/null weren't allowed, super’s -validateValue:error: would have failed
        return YES;
    }

    if (outError) {
        NSString *descriptionFormat = TWTLocalizedString(@"TWTRegularExpressionStringValidator.validationError");
        NSString *description = [NSString stringWithFormat:descriptionFormat, [self.regularExpression pattern]];
        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueDoesNotMatchFormat
                                        failingValidator:self
                                                   value:value
                                    localizedDescription:description];
    }

    return NO;
}

@end

#pragma mark

@implementation TWTPrefixStringValidator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (instancetype)initWithPrefixString:(NSString *)prefix caseSensitive:(BOOL)caseSensitive
{
    NSParameterAssert(prefix);
    self = [super init];
    if (self) {
        _prefix = [prefix copy];
        _validatesCase = caseSensitive;
    }
    
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.prefix = self.prefix;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.prefix.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return [other.prefix isEqualToString:self.prefix];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value)) {
        // This will only happen if nil or null is allowed
        return YES;
    }
    
    NSInteger errorCode = -1;
    
    NSStringCompareOptions options = (self.validatesCase ? 0 : NSCaseInsensitiveSearch) | NSAnchoredSearch;
    NSRange range = [value rangeOfString:self.prefix
                                 options:options];

    if (range.length == 0) {
        errorCode = TWTValidationErrorCodeValueDoesNotMatchFormat;
    } else {
        return YES;
    }
    
    if (outError) {
        NSString *description = [NSString stringWithFormat:TWTLocalizedString(@"TWTPrefixStringValidator.validationError.format"), self.prefix];
        *outError = [NSError twt_validationErrorWithCode:errorCode failingValidator:self value:value localizedDescription:description];
    }
    
    return NO;
}

@end


#pragma mark

@implementation TWTSuffixStringValidator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (instancetype)initWithSuffixString:(NSString *)prefix caseSensitive:(BOOL)caseSensitive
{
    NSParameterAssert(prefix);
    self = [super init];
    if (self) {
        _suffix = [prefix copy];
        _validatesCase = caseSensitive;
    }
    
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.suffix = self.suffix;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.suffix.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return [other.suffix isEqualToString:self.suffix];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value)) {
        // This will only happen if nil or null is allowed
        return YES;
    }
    
    NSInteger errorCode = -1;
    
    NSStringCompareOptions options = (self.validatesCase ? 0 : NSCaseInsensitiveSearch) | NSAnchoredSearch | NSBackwardsSearch;
    NSRange range = [value rangeOfString:self.suffix
                                 options:options];
    
    if (range.length == 0) {
        errorCode = TWTValidationErrorCodeValueDoesNotMatchFormat;
    } else {
        return YES;
    }
    
    if (outError) {
        NSString *description = [NSString stringWithFormat:TWTLocalizedString(@"TWTSuffixStringValidator.validationError.format"), self.suffix];
        *outError = [NSError twt_validationErrorWithCode:errorCode failingValidator:self value:value localizedDescription:description];
    }
    
    return NO;
}

@end


#pragma mark

@implementation TWTSubstringValidator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (instancetype)initWithSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive
{
    NSParameterAssert(substring);
    self = [super init];
    if (self) {
        _substring = [substring copy];
        _validatesCase = caseSensitive;
    }
    
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.substring = self.substring;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.substring.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return [other.substring isEqualToString:self.substring];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value)) {
        // This will only happen if nil or null is allowed
        return YES;
    }
    
    NSInteger errorCode = -1;
    
    NSStringCompareOptions options = self.validatesCase ? 0 : NSCaseInsensitiveSearch;
    NSRange range = [value rangeOfString:self.substring
                                 options:options];
    
    if (range.length == 0) {
        errorCode = TWTValidationErrorCodeValueDoesNotMatchFormat;
    } else {
        return YES;
    }
    
    if (outError) {
        NSString *description = [NSString stringWithFormat:TWTLocalizedString(@"TWTSubstringValidator.validationError.format"), self.substring];
        *outError = [NSError twt_validationErrorWithCode:errorCode failingValidator:self value:value localizedDescription:description];
    }
    
    return NO;
}

@end


#pragma mark

@implementation TWTWildcardMatchingStringValidatator

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (instancetype)initWithMatchingString:(NSString *)matchingString caseSensitive:(BOOL)caseSensitive
{
    NSParameterAssert(matchingString);
    self = [super init];
    if (self) {
        _matchingString = [matchingString copy];
        _validatesCase = caseSensitive;
        _predicateFormat = [NSString stringWithFormat:@"SELF LIKE%@ %%@", caseSensitive ? @"" : @"[cd]"];
    }
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.matchingString = self.matchingString;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.matchingString.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return [other.matchingString isEqualToString:self.matchingString];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value)) {
        // This will only happen if nil or null is allowed
        return YES;
    }
    
    NSInteger errorCode = -1;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:self.predicateFormat, self.matchingString];
    BOOL matches = [predicate evaluateWithObject:value];
    
    if (!matches) {
        errorCode = TWTValidationErrorCodeValueDoesNotMatchFormat;
    } else {
        return YES;
    }

    if (outError) {
        NSString *description = [NSString stringWithFormat:TWTLocalizedString(@"TWTSubstringValidator.validationError.format"), self.matchingString];
        *outError = [NSError twt_validationErrorWithCode:errorCode failingValidator:self value:value localizedDescription:description];
    }
    
    return NO;
}


@end
