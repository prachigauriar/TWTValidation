//
//  main.m
//  ValidationTest
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TWTValidation/TWTValidation.h>

#import "TWTObject.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        TWTObject *object = [[TWTObject alloc] init];
        object.thing = @"poop";
        
        NSError *error = nil;
        BOOL validated = [object validateValueForKey:@"thing" error:&error];

        NSLog(@"validated = %@; error = %@", validated ? @"YES" : @"NO", [error description]);
    }

    return 0;
}

