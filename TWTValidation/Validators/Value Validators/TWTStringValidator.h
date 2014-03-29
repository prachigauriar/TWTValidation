//
//  TWTStringValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/27/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValueValidator.h>

@interface TWTStringValidator : TWTValueValidator <NSCopying>

+ (instancetype)stringValidatorWithLength:(NSUInteger)length;
+ (instancetype)stringValidatorWithMinimumLength:(NSUInteger)minimumLength maximumLength:(NSUInteger)maximumLength;
+ (instancetype)stringValidatorWithRegularExpression:(NSRegularExpression *)regularExpression options:(NSMatchingOptions)options;

@end


@interface TWTBoundedLengthStringValidator : TWTStringValidator <NSCopying>

@property (nonatomic, assign, readonly) NSUInteger minimumLength;
@property (nonatomic, assign, readonly) NSUInteger maximumLength;

- (instancetype)initWithMinimumLength:(NSUInteger)minimumLength maximumLength:(NSUInteger)maximumLength;

@end


@interface TWTRegularExpressionStringValidator : TWTStringValidator

@property (nonatomic, strong, readonly) NSRegularExpression *regularExpression;
@property (nonatomic, assign, readonly) NSMatchingOptions options;

- (instancetype)initWithRegularExpression:(NSRegularExpression *)regularExpression options:(NSMatchingOptions)options;

@end
