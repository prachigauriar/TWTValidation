//
//  TWTKeyValuePairValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
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

#import <TWTValidation/TWTKeyValuePairValidator.h>

#import <TWTValidation/TWTValidationErrors.h>


@interface TWTKeyValuePairValidator ()

@property (nonatomic, strong, readwrite) id key;
@property (nonatomic, strong, readwrite) TWTValidator *valueValidator;

@end


@implementation TWTKeyValuePairValidator

- (instancetype)init
{
    return [self initWithKey:nil valueValidator:nil];
}


- (instancetype)initWithKey:(id)key valueValidator:(TWTValidator *)valueValidator
{
    NSParameterAssert(key);
    self = [super init];
    if (self) {
        _key = key;
        _valueValidator = valueValidator;
    }
    
    return self;
}


- (NSUInteger)hash
{
    return [super hash] ^ [self.key hash] ^ self.valueValidator.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return [other.key isEqual:self.key] && [other.valueValidator isEqual:self.valueValidator];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    return !self.valueValidator || [self.valueValidator validateValue:value error:outError];
}

@end
