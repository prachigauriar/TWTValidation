//
//  TWTCompoundValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValidator.h>

typedef NS_ENUM(NSUInteger, TWTCompoundValidatorType) {
    TWTCompoundValidatorTypeAnd = 1,
    TWTCompoundValidatorTypeOr,
    TWTCompoundValidatorTypeMutualExclusion,
};

@interface TWTCompoundValidator : TWTValidator <NSCopying>

@property (nonatomic, assign, readonly) TWTCompoundValidatorType compoundValidatorType;
@property (nonatomic, copy, readonly) NSArray *subvalidators;

+ (instancetype)andValidatorWithSubvalidators:(NSArray *)subvalidators;
+ (instancetype)orValidatorWithSubvalidators:(NSArray *)subvalidators;
+ (instancetype)mutualExclusionValidatorWithSubvalidators:(NSArray *)subvalidators;

- (instancetype)initWithType:(TWTCompoundValidatorType)type subvalidators:(NSArray *)subvalidators;

@end
