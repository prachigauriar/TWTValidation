//
//  TWTCompoundValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
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

#import <TWTValidation/TWTValidator.h>

/*! Compound validator types. */
typedef NS_ENUM(NSUInteger, TWTCompoundValidatorType) {
    /*! The logical-not compound validator type. */
    TWTCompoundValidatorTypeNot,

    /*! The logical-and compound validator type. */
    TWTCompoundValidatorTypeAnd,

    /*! The logical-or compound validator type. */
    TWTCompoundValidatorTypeOr,

    /*! The mutual exclusion compound validator type. */
    TWTCompoundValidatorTypeMutualExclusion,
};


/*!
 TWTCompoundValidators validate values by aggregating the validation results of zero or more subvalidators.
 There are four types of compound validators: Not validators, And validators, Or validators, and Mutual
 Exclusion validators. These behave as one would expect: Not validators pass validation only if its
 subvalidator fails. And validators pass if and only if validation passes for all its subvalidators. For Or
 validators, validation passes if and only if at least one of its subvalidators passes validation. Validation
 passes for a Mutual Exclusion validator only if exactly one subvalidator passes validation.

 It is important to note that compound validators do not short-circuit validation. All of a compound
 validator’s subvalidators validate a value before the compound validator returns from -validateValue:error:.

 Compound validators are immutable objects. As such, sending -copy or -copyWithZone: to a compound validator
 will simply return the validator itself.
 */
@interface TWTCompoundValidator : TWTValidator <NSCopying>

/*! 
 @abstract The instance’s compound validator type. 
 @discussion TWTCompoundValidatorTypeAnd by default.
 */
@property (nonatomic, assign, readonly) TWTCompoundValidatorType compoundValidatorType;

/*! 
 @abstract The instance’s subvalidators. 
 @discussion If nil or empty, And validators will successfully validate all values, and Or and Mutual
     Exclusion validators will never successfully validate a value. nil by default.
 */
@property (nonatomic, copy, readonly) NSArray *subvalidators;

/*!
 @abstract Initializes a newly created compound validator with the specified type and subvalidators.
 @discussion This is the class’s designated initializer.
 
     Not validators consider a value valid only if its sole subvalidator considers it invalid. And validators
     consider a value valid only if all of its subvalidators also consider the value valid. At least one of an
     Or validator’s subvalidators must validate a value for it to also validate the value. Mutual Exclusion
     validators only validate a value if exactly one of its subvalidators validates the value.
 @param type The type of compound validator.
 @param subvalidators The instance’s subvalidators. If nil or empty, And validators will successfully validate
     all values, and Or and Mutual Exclusion validators will never successfully validate a value. Not
     validators must have at least one subvalidator.
 @result An initialized compound validator with the specified type and subvalidators.
 */
- (instancetype)initWithType:(TWTCompoundValidatorType)type subvalidators:(NSArray *)subvalidators;

/*!
 @abstract Creates and returns a Not validator with the specified subvalidator.
 @discussion A Not validator considers a value valid only if its subvalidator considers the value invalid.
 @param subvalidator The instance’s subvalidator. May not be nil.
 @result A Not validator with the specified subvalidator.
 */
+ (instancetype)notValidatorWithSubvalidator:(TWTValidator *)subvalidator;

/*!
 @abstract Creates and returns an And validator with the specified subvalidators.
 @discussion An And validator considers a value valid only if all its subvalidators consider the value valid.
 @param subvalidators The instance’s subvalidators. If nil or empty, the returned validator will successfully
     validate all values.
 @result An And validator with the specified subvalidators.
 */
+ (instancetype)andValidatorWithSubvalidators:(NSArray *)subvalidators;

/*!
 @abstract Creates and returns an Or validator with the specified subvalidators.
 @discussion An Or validator considers a value valid only if at least one of its subvalidators considers the
     value valid.
 @param subvalidators The instance’s subvalidators. If nil or empty, the returned validator will never
     successfully validate a value.
 @result An Or validator with the specified subvalidators.
 */
+ (instancetype)orValidatorWithSubvalidators:(NSArray *)subvalidators;

/*!
 @abstract Creates and returns a Mutal Exclusion validator with the specified subvalidators.
 @discussion A Mutual Exclusion validator considers a value valid only if exactly one of its subvalidators
     considers the value valid.
 @param subvalidators The instance’s subvalidators. If nil or empty, the returned validator will never
     successfully validate a value.
 @result A Mutual Exclusion validator with the specified subvalidators.
 */
+ (instancetype)mutualExclusionValidatorWithSubvalidators:(NSArray *)subvalidators;

@end
