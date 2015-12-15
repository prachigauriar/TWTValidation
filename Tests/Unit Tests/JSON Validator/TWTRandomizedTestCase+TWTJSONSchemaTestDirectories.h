//
//  TWTRandomizedTestCase+TWTJSONSchemaTestDirectories.h
//  TWTValidation
//
//  Created by Jill Cohen on 12/14/15.
//  Copyright © 2015 Ticketmaster Entertainment, Inc. All rights reserved.
//

#import "TWTRandomizedTestCase.h"


// Converts the preprocessor macros for test directory paths into strings
#define STRING_FROM_SYMBOL(x) #x
#define STRING_FROM_MACRO(x) STRING_FROM_SYMBOL(x)


@interface TWTRandomizedTestCase (TWTJSONSchemaTestDirectories)

+ (NSString *)twt_pathForTestSuite;

+ (NSString *)twt_pathForDraft4TestSuite;

+ (NSString *)twt_pathForCustomTests;

@end
