//
//  TWTStringValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/27/2014.
//  Copyright (c) 2015 Ticketmaster. All rights reserved.
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
@property (nonatomic, assign, readwrite, getter = isCaseSensitive) BOOL caseSensitive;

@end

#pragma mark

@interface TWTSuffixStringValidator ()

@property (nonatomic, copy, readwrite) NSString *suffix;
@property (nonatomic, assign, readwrite, getter = isCaseSensitive) BOOL caseSensitive;

@end


#pragma mark

@interface TWTSubstringStringValidator ()

@property (nonatomic, copy, readwrite) NSString *substring;
@property (nonatomic, assign, readwrite, getter = isCaseSensitive) BOOL caseSensitive;

@end


#pragma mark

@interface TWTWildcardPatternStringValidator ()

@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, copy, readwrite) NSString *pattern;
@property (nonatomic, assign, readwrite, getter = isCaseSensitive) BOOL caseSensitive;

@end

#pragma mark

@interface TWTCharacterSetStringValidator ()

@property (nonatomic, copy, readwrite) NSCharacterSet *characterSet;
@property (nonatomic, copy) NSCharacterSet *invertedCharacterSet;

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


+ (TWTBoundedComposedCharacterLengthStringValidator *)stringValidatorWithComposedCharacterMinimumLength:(NSUInteger)minimumLength maximumLength:(NSUInteger)maximumLength
{
    return [[TWTBoundedComposedCharacterLengthStringValidator alloc] initWithMinimumLength:minimumLength maximumLength:maximumLength];
}


+ (TWTRegularExpressionStringValidator *)stringValidatorWithRegularExpression:(NSRegularExpression *)regularExpression options:(NSMatchingOptions)options
{
    return [[TWTRegularExpressionStringValidator alloc] initWithRegularExpression:regularExpression options:options];
}


+ (TWTPrefixStringValidator *)stringValidatorWithPrefix:(NSString *)prefix caseSensitive:(BOOL)caseSensitve
{
    return [[TWTPrefixStringValidator alloc] initWithPrefix:prefix caseSensitive:caseSensitve];
}


+ (TWTSuffixStringValidator *)stringValidatorWithSuffix:(NSString *)suffix caseSensitive:(BOOL)caseSensitive
{
    return [[TWTSuffixStringValidator alloc] initWithSuffix:suffix caseSensitive:caseSensitive];
}


+ (TWTSubstringStringValidator *)stringValidatorWithSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive
{
    return [[TWTSubstringStringValidator alloc] initWithSubstring:substring caseSensitive:caseSensitive];
}


+ (TWTWildcardPatternStringValidator *)stringValidatorWithPattern:(NSString *)pattern caseSensitive:(BOOL)caseSensitive
{
    return [[TWTWildcardPatternStringValidator alloc] initWithPattern:pattern caseSensitive:caseSensitive];
}


+ (TWTCharacterSetStringValidator *)stringValidatorWithCharacterSet:(NSCharacterSet *)characterSet
{
    return [[TWTCharacterSetStringValidator alloc] initWithCharacterSet:characterSet];
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

    NSUInteger length = [self lengthOfString:value];
    if (length < self.minimumLength) {
        errorCode = TWTValidationErrorCodeLengthLessThanMinimum;
    } else if (length > self.maximumLength) {
        errorCode = TWTValidationErrorCodeLengthGreaterThanMaximum;
    } else {
        return YES;
    }

    if (outError) {
        NSString *description = nil;
        switch (errorCode) {
            case TWTValidationErrorCodeLengthLessThanMinimum: {
                NSString *descriptionFormat = TWTLocalizedString(@"TWTBoundedLengthStringValidator.lengthLessThanMinimum.validationError.format");
                description = [NSString stringWithFormat:descriptionFormat, (unsigned long)length, (unsigned long)self.minimumLength];
                break;
            }
            case TWTValidationErrorCodeLengthGreaterThanMaximum: {
                NSString *descriptionFormat = TWTLocalizedString(@"TWTBoundedLengthStringValidator.lengthGreaterThanMaximum.validationError.format");
                description = [NSString stringWithFormat:descriptionFormat, (unsigned long)length, (unsigned long)self.minimumLength];
                break;
            }
        }

        *outError = [NSError twt_validationErrorWithCode:errorCode failingValidator:self value:value localizedDescription:description];
    }
    
    return NO;
}


- (NSUInteger)lengthOfString:(NSString *)string
{
    return [string length];
}

@end


#pragma mark

@implementation TWTBoundedComposedCharacterLengthStringValidator

- (NSUInteger)lengthOfString:(NSString *)string
{
    return [string lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
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
        NSString *descriptionFormat = TWTLocalizedString(@"TWTRegularExpressionStringValidator.validationError.format");
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
    return [self initWithPrefix:nil caseSensitive:YES];
}


- (instancetype)initWithPrefix:(NSString *)prefix caseSensitive:(BOOL)caseSensitive
{
    self = [super init];
    if (self) {
        _prefix = [prefix copy];
        _caseSensitive = caseSensitive;
    }
    
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.prefix = self.prefix;
    copy.caseSensitive = self.isCaseSensitive;
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
    return other.isCaseSensitive == self.isCaseSensitive && [other.prefix isEqualToString:self.prefix];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value) || !self.prefix) {
        // This will only happen if nil or null is allowed or the default expectations are not met
        return YES;
    }

    NSRange range = [value rangeOfString:self.prefix options:(self.isCaseSensitive ? 0 : NSCaseInsensitiveSearch) | NSAnchoredSearch];
    if (range.location != NSNotFound) {
        return YES;
    }

    if (outError) {
        NSString *description = [NSString stringWithFormat:TWTLocalizedString(@"TWTPrefixStringValidator.validationError.format"), self.prefix];
        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueDoesNotMatchFormat
                                        failingValidator:self
                                                   value:value
                                    localizedDescription:description];
    }
    
    return NO;
}

@end


#pragma mark

@implementation TWTSuffixStringValidator

- (instancetype)init
{
    return [self initWithSuffix:nil caseSensitive:YES];
}


- (instancetype)initWithSuffix:(NSString *)prefix caseSensitive:(BOOL)caseSensitive
{
    self = [super init];
    if (self) {
        _suffix = [prefix copy];
        _caseSensitive = caseSensitive;
    }
    
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.suffix = self.suffix;
    copy.caseSensitive = self.isCaseSensitive;
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
    return other.isCaseSensitive == self.isCaseSensitive && [other.suffix isEqualToString:self.suffix];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value) || !self.suffix) {
        // This will only happen if nil or null is allowed or the default expectations are not met
        return YES;
    }
    
    NSRange range = [value rangeOfString:self.suffix options:(self.isCaseSensitive ? 0 : NSCaseInsensitiveSearch) | NSAnchoredSearch | NSBackwardsSearch];
    if (range.location != NSNotFound) {
        return YES;
    }
    
    if (outError) {
        NSString *description = [NSString stringWithFormat:TWTLocalizedString(@"TWTSuffixStringValidator.validationError.format"), self.suffix];
        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueDoesNotMatchFormat
                                        failingValidator:self
                                                   value:value
                                    localizedDescription:description];
    }
    
    return NO;
}

@end


#pragma mark

@implementation TWTSubstringStringValidator

- (instancetype)init
{
    return [self initWithSubstring:nil caseSensitive:YES];
}


- (instancetype)initWithSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive
{
    self = [super init];
    if (self) {
        _substring = [substring copy];
        _caseSensitive = caseSensitive;
    }
    
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.caseSensitive = self.isCaseSensitive;
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
    return other.isCaseSensitive == self.isCaseSensitive && [other.substring isEqualToString:self.substring];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value) || !self.substring) {
        // This will only happen if nil or null is allowed or the default expectations are not met
        return YES;
    }
    
    NSRange range = [value rangeOfString:self.substring options:(self.isCaseSensitive ? 0 : NSCaseInsensitiveSearch)];
    if (range.location != NSNotFound) {
        return YES;
    }
    
    if (outError) {
        NSString *description = [NSString stringWithFormat:TWTLocalizedString(@"TWTSubstringStringValidator.validationError.format"), self.substring];
        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueDoesNotMatchFormat
                                        failingValidator:self
                                                   value:value
                                    localizedDescription:description];
    }
    
    return NO;
}

@end


#pragma mark

@implementation TWTWildcardPatternStringValidator

- (instancetype)init
{
    return [self initWithPattern:nil caseSensitive:YES];
}


- (instancetype)initWithPattern:(NSString *)pattern caseSensitive:(BOOL)caseSensitive
{
    self = [super init];
    if (self) {
        _pattern = [pattern copy];
        _caseSensitive = caseSensitive;
    }
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.pattern = self.pattern;
    copy.caseSensitive = self.isCaseSensitive;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.pattern.hash;
}


- (NSPredicate *)predicate
{
    if (self.pattern && !_predicate) {
        NSString *predicateString = [NSString stringWithFormat:@"SELF LIKE%@ %%@", self.isCaseSensitive ? @"" : @"[c]"];
        self.predicate = [NSPredicate predicateWithFormat:predicateString, self.pattern];
    }

    return _predicate;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return other.isCaseSensitive == self.isCaseSensitive && [other.pattern isEqualToString:self.pattern];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value) || !self.pattern) {
        // This will only happen if nil or null is allowed or the default expectations are not met
        return YES;
    }
    
    if ([self.predicate evaluateWithObject:value]) {
        return YES;
    }

    if (outError) {
        NSString *description = [NSString stringWithFormat:TWTLocalizedString(@"TWTWildcardPatternStringValidatator.validationError.format"), self.pattern];
        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueDoesNotMatchFormat
                                        failingValidator:self
                                                   value:value
                                    localizedDescription:description];
    }
    
    return NO;
}

@end


#pragma mark

@implementation TWTCharacterSetStringValidator

- (instancetype)init
{
    return [self initWithCharacterSet:nil];
}


- (instancetype)initWithCharacterSet:(NSCharacterSet *)characterSet
{
    self = [super init];
    if (self) {
        _characterSet = characterSet;
    }
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.characterSet = self.characterSet;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.characterSet.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return [other.characterSet isEqual:self.characterSet];
}


- (NSCharacterSet *)invertedCharacterSet
{
    if (!_invertedCharacterSet) {
        self.invertedCharacterSet = self.characterSet.invertedSet;
    }

    return _invertedCharacterSet;
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value) || !self.characterSet) {
        // This will only happen if nil or null is allowed or the default expectations are not met
        return YES;
    }
    
    NSRange range = [value rangeOfCharacterFromSet:self.invertedCharacterSet];
    if (range.location == NSNotFound) {
        return YES;
    }
    
    if (outError) {
        NSString *description = TWTLocalizedString(@"TWTCharacterSetStringValidator.validationError");
        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueDoesNotMatchFormat
                                        failingValidator:self
                                                   value:value
                                    localizedDescription:description];
    }
    
    return NO;
}

@end
