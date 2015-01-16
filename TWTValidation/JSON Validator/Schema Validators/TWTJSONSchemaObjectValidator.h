//
//  TWTJSONSchemaObjectValidator.h
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

#import <TWTValidation/TWTValidation.h>


@interface TWTJSONSchemaObjectValidator : TWTValidator

@property (nonatomic, strong, readonly) NSNumber *maximumPropertyCount;
@property (nonatomic, strong, readonly) NSNumber *minimumPropertyCount;
@property (nonatomic, copy, readonly) NSSet *requiredPropertyKeys;
@property (nonatomic, copy, readonly) NSArray *propertyValidators;
@property (nonatomic, copy, readonly) NSArray *patternPropertyValidators;
// either always passing, always failing, or a JSONObjectValidator
@property (nonatomic, strong, readonly) TWTValidator *additionalPropertiesValidator;
@property (nonatomic, copy) NSDictionary *propertyDependencies; 


- (instancetype)initWithMaximumPropertyCount:(NSNumber *)maximumPropertyCount
                        minimumPropertyCount:(NSNumber *)minimumPropertyCount
                        requiredPropertyKeys:(NSSet *)requiredPropertyKeys
                          propertyValidators:(NSArray *)propertyValidators
                   patternPropertyValidators:(NSArray *)patternPropertyValidators
               additionalPropertiesValidator:(TWTValidator *)additionalPropertiesValidator
                        propertyDependencies:(NSDictionary *)propertyDependencies;

@end
