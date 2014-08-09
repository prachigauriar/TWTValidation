//
//  TWTRandomizedTestCase.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/30/2014.
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

#import "TWTRandomizedTestCase.h"


#pragma mark Passing Validator

@interface TWTPassingValidator : TWTValidator

@end


@implementation TWTPassingValidator

- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    return YES;
}

@end



#pragma mark - Failing Validator

@interface TWTFailingValidator : TWTValidator

@property (nonatomic, strong, readonly) NSError *error;

- (instancetype)initWithError:(NSError *)error;

@end


@implementation TWTFailingValidator

- (instancetype)initWithError:(NSError *)error
{
    self = [super init];
    if (self) {
        _error = error;
    }

    return self;
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (outError) {
        *outError = self.error;
    }

    return NO;
}


- (NSUInteger)hash
{
    return [super hash] ^ [self.error hash];
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }

    return [self.error isEqual:[object error]];
}

@end


#pragma mark

@implementation TWTRandomizedTestCase

+ (void)setUp
{
    [super setUp];
    srandomdev();
}


- (void)setUp
{
    [super setUp];
    unsigned seed = (unsigned)random();
    NSLog(@"Using seed %d", seed);
    srandom(seed);
}


- (id)randomObject
{
    switch (random() % 6) {
        case 0:
            return [NSNull null];
        case 1:
            return UMKRandomUnsignedNumber();
        case 2:
            return UMKRandomUnicodeString();
        case 3:
            return UMKRandomAlphanumericString();
        case 4:
            return UMKRandomHTTPURL();
        default:
            return nil;
    }
}


- (Class)randomClass
{
    switch (random() % 5) {
        case 0:
            return [NSNull class];
        case 1:
            return [NSNumber class];
        case 2:
            return [NSString class];
        case 3:
            return [NSURL class];
        default:
            return Nil;
    }
}


- (Class)randomClassWithMutableVariant
{
    switch (random() % 5) {
        case 0:
            return [NSArray class];
        case 1:
            return [NSData class];
        case 2:
            return [NSDictionary class];
        case 3:
            return [NSSet class];
        default:
            return [NSString class];
    }    
}


- (TWTValidator *)randomValidator
{
    return UMKRandomBoolean() ? [self.class passingValidator] : [self.class failingValidatorWithError:UMKRandomError()];
}


- (TWTValidator *)passingValidator
{
    return [self.class passingValidator];
}


- (TWTValidator *)failingValidatorWithError:(NSError *)error
{
    return [self.class failingValidatorWithError:error];
}


+ (TWTValidator *)passingValidator
{
    return [[TWTPassingValidator alloc] init];
}


+ (TWTValidator *)failingValidatorWithError:(NSError *)error
{
    return [[TWTFailingValidator alloc] initWithError:error];
}

@end
