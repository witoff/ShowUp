//
//  ContactProvider.h
//  perspect calendar
//
//  Created by Robert Witoff on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactProvider : NSObject

- (NSArray*) getAllContacts;

+(ContactProvider*)defaultProvider;
+(void)setDefaultProvider:(ContactProvider*)provider;

@end
