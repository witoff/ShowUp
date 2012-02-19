//
//  ScanAddressBook.h
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScanAddressBook : NSObject

- (void) search;
- (NSArray*) getContacts;
- (NSString*) simpleSearch:(NSString*)lastName;

@end
