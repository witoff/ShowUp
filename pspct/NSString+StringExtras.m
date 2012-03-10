//
//  NSString+StringExtras.m
//  perspect
//
//  Created by Robert Witoff on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+StringExtras.h"

@implementation NSString (StringExtras)

- (BOOL) containsString:(NSString *) string
                options:(NSStringCompareOptions) options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL) containsString:(NSString *) string {
    return [self containsString:string options:0];
}


@end
