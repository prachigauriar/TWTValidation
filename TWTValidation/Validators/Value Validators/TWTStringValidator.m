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
@property (nonatomic, copy) NSString *wildcardPattern;
@property (nonatomic, assign, readwrite, getter = isCaseSensitive) BOOL caseSensitive;

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


+ (TWTWildcardPatternStringValidator *)stringValidatorWithWildcardPattern:(NSString *)pattern caseSensitive:(BOOL)caseSensitive
{
    return [[TWTWildcardPatternStringValidator alloc] initWithWildcardPattern:pattern caseSensitive:caseSensitive];
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
    
    NSInteger errorCode = -1;
    
    NSStringCompareOptions options = self.caseSensitive ? 0 : NSCaseInsensitiveSearch;
    NSRange range = [value rangeOfString:self.substring
                                 options:options];
    
    if (range.location == NSNotFound) {
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

@implementation TWTWildcardPatternStringValidator

- (instancetype)init
{
    return [self initWithWildcardPattern:nil caseSensitive:YES];
}


- (instancetype)initWithWildcardPattern:(NSString *)pattern caseSensitive:(BOOL)caseSensitive
{
    self = [super init];
    if (self) {
        _wildcardPattern = [pattern copy];
        _caseSensitive = caseSensitive;
        
        if (_wildcardPattern) {
            NSString *predicateString = [NSString stringWithFormat:@"SELF LIKE%@ %%@", caseSensitive ? @"" : @"[c]"];
            _predicate = [NSPredicate predicateWithFormat:predicateString, _wildcardPattern];
        }
    }
    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.wildcardPattern = self.wildcardPattern;
    copy.caseSensitive = self.isCaseSensitive;
    copy.predicate = self.predicate;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.wildcardPattern.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return other.isCaseSensitive == self.isCaseSensitive && [other.wildcardPattern isEqualToString:self.wildcardPattern];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value) || !self.wildcardPattern) {
        // This will only happen if nil or null is allowed or the default expectations are not met
        return YES;
    }
    
    if ([self.predicate evaluateWithObject:value]) {
        return YES;
    }

    if (outError) {
        NSString *description = [NSString stringWithFormat:TWTLocalizedString(@"TWTWildcardMatchingStringValidatator.validationError.format"),
                                                           self.wildcardPattern];
        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueDoesNotMatchFormat
                                        failingValidator:self
                                                   value:value
                                    localizedDescription:description];
    }
    
    return NO;
}


@end
