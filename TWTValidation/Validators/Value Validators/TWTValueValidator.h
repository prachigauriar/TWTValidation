//
//  TWTValueValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValidator.h>

@interface TWTValueValidator : TWTValidator <NSCopying>

@property (nonatomic, assign) BOOL allowsNil;
@property (nonatomic, assign) BOOL allowsNull;
@property (nonatomic, unsafe_unretained) Class valueClass;

+ (instancetype)valueValidatorWithClass:(Class)valueClass allowsNil:(BOOL)allowsNil allowsNull:(BOOL)allowsNull;

@end


static inline BOOL TWTValidatorValueIsNilOrNull(id value)
{
    return !value || [[NSNull null] isEqual:value];
}
