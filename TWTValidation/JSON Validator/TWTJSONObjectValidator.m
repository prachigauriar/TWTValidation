//
//  TWTJSONObjectValidator.m
//  TWTValidation
//
//  Created by Jill Cohen on 1/14/15.
//  Copyright (c) 2015 Two Toasters, LLC.
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

#import <TWTValidation/TWTJSONObjectValidator.h>

#import <TWTValidation/TWTJSONObjectValidatorGenerator.h>


@interface TWTJSONObjectValidator ()

@property (nonatomic, copy, readwrite) NSDictionary *schema;

@property (nonatomic, strong, readonly) TWTValidator *commonValidator;
@property (nonatomic, strong, readonly) TWTValidator *typeValidator;
@property (nonatomic, assign, readonly) BOOL requiresType;
@property (nonatomic, assign, readonly) TWTJSONType type;

@end


@implementation TWTJSONObjectValidator

+ (TWTJSONObjectValidator *)validatorWithJSONSchema:(NSDictionary *)schema error:(NSError *__autoreleasing *)outError warnings:(NSArray *__autoreleasing *)outWarnings
{
    NSParameterAssert(schema);
    TWTJSONObjectValidatorGenerator *generator = [[TWTJSONObjectValidatorGenerator alloc] init];
    TWTJSONObjectValidator *validator = [generator validatorFromJSONSchema:schema error:outError warnings:outWarnings];
    validator.schema = [schema copy];

    return validator;
}


- (instancetype)initWithCommonValidator:(TWTValidator *)commonValidator typeValidator:(TWTValidator *)typeValidator type:(TWTJSONType)type requiresType:(BOOL)requiresType
{
    if (requiresType && type != TWTJSONTypeAny) {
        NSParameterAssert(typeValidator);
    }

    self = [super init];
    if (self) {
        _commonValidator = [commonValidator copy];
        _typeValidator = [typeValidator copy];
        _type = type;
        _requiresType = requiresType;
    }
    return self;
}


- (instancetype)init
{
    return [self initWithCommonValidator:nil typeValidator:nil type:TWTJSONTypeAny requiresType:NO];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    // Does not call super becaues NULL can be valid 
    if (!self.commonValidator && !self.typeValidator) {
        return YES;
    }

    BOOL commonKeywordsValidated = YES;
    BOOL typeKeywordsValidated = YES;

    NSError *commonError = nil;
    NSError *typeError = nil;

    if (self.commonValidator) {
        commonKeywordsValidated = [self.commonValidator validateValue:value error:outError ? &commonError : NULL];
    }

    if (!self.typeValidator || !(self.requiresType || [self valueMatchesType:value])) {
        if (!commonKeywordsValidated && outError) {
            *outError = commonError;
        }
        return commonKeywordsValidated;
    }

    typeKeywordsValidated = [self.typeValidator validateValue:value error:outError ? &typeError : NULL];
    BOOL validated = commonKeywordsValidated && typeKeywordsValidated;

    if (!validated && outError) {
        //errors
    }

    return validated;
}


- (BOOL)valueMatchesType:(id)value
{
    switch (self.type) {
        case TWTJSONTypeObject:
            return [value isKindOfClass:[NSDictionary class]];

        case TWTJSONTypeArray:
            return [value isKindOfClass:[NSArray class]];

        case TWTJSONTypeBoolean:
            if ([value isKindOfClass:[NSNumber class]]) {
                return strcmp([(NSValue *)value objCType], @encode(BOOL)) == 0;
            }
            return NO;

        case TWTJSONTypeString:
            return [value isKindOfClass:[NSString class]];

        case TWTJSONTypeNumber:
            if ([value isKindOfClass:[NSNumber class]]) {
                return strcmp([(NSValue *)value objCType], @encode(BOOL)) != 0;
            };
            return NO;

        case TWTJSONTypeNull:
            return [value isKindOfClass:[NSNull class]];

        case TWTJSONTypeAmbiguous:
        case TWTJSONTypeAny:
            return YES;
    }
}

@end
