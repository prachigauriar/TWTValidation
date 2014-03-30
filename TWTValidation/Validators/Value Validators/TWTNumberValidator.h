//
//  TWTNumberValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValueValidator.h>

@interface TWTNumberValidator : TWTValueValidator <NSCopying>

@property (nonatomic, assign) BOOL requiresIntegralValue;
@property (nonatomic, strong, readonly) NSNumber *minimum;
@property (nonatomic, strong, readonly) NSNumber *maximum;

+ (instancetype)numberValidatorWithMinimum:(NSNumber *)minimum maximum:(NSNumber *)maximum;

- (instancetype)initWithMinimum:(NSNumber *)minimum maximum:(NSNumber *)maximum;

@end
