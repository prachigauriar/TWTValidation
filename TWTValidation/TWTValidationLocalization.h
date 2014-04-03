//
//  TWTValidationLocalization.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 4/3/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#define TWTLocalizedString(key) \
    [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:@"TWTValidation"]
