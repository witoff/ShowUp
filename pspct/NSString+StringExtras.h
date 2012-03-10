//
//  NSString+StringExtras.h
//  perspect
//
//  Created by Robert Witoff on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringExtras)

- (BOOL) containsString:(NSString *) string;
- (BOOL) containsString:(NSString *) string
                options:(NSStringCompareOptions) options;

@end
