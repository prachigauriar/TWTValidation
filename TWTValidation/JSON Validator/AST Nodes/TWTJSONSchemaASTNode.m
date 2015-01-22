//
//  TWTJSONSchemaASTNode.m
//  TWTValidation
//
//  Created by Jill Cohen on 12/12/14.
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

#import <TWTValidation/TWTJSONSchemaASTNode.h>

#import <URLMock/NSException+UMKSubclassResponsibility.h>


@implementation TWTJSONSchemaASTNode

- (void)acceptProcessor:(id)processor
{
    [NSException umk_subclassResponsibilityExceptionWithReceiver:self selector:_cmd];
}


- (NSSet *)validTypes
{
    [NSException umk_subclassResponsibilityExceptionWithReceiver:self selector:_cmd];
    return nil;
}
//
//
//- (NSSet *)validClasses
//{
//    NSMutableSet *classes = [[NSMutableSet alloc] init];
//    NSSet *type = self.validTypes;
//
//    if ([type containsObject:TWTJSONSchemaTypeKeywordArray]) {
//        [classes addObject:[NSArray class]];
//    }
//    if ([type containsObject:TWTJSONSchemaTypeKeywordNumber] || [type containsObject:TWTJSONSchemaTypeKeywordInteger]) {
//        [classes addObject:[NSNumber class]];
//    }
//    if ([type containsObject:TWTJSONSchemaTypeKeywordObject]) {
//        node = [[TWTJSONSchemaObjectASTNode alloc] init];
//        [self parseObjectSchema:schema intoNode:node];
//    }
//    if ([type containsObject:TWTJSONSchemaTypeKeywordString]) {
//        node = [[TWTJSONSchemaStringASTNode alloc] init];
//        [self parseStringSchema:schema intoNode:node];
//    }
//    {
//        // type = "any", "boolean", or "null"
//        node = [[TWTJSONSchemaGenericASTNode alloc] init];
//        [self parseGenericSchema:schema intoNode:node withType:type];
//    }
//
//}

@end

