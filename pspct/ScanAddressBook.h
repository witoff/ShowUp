//
//  ScanAddressBook.h
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScanAddressBook : NSObject
{
    NSArray* contacts;
}

@property (nonatomic, retain) NSArray* contacts;

- (void) search;
- (NSArray*) getContacts;
- (NSString*) simpleSearch:(NSString*)firstname andLastName:(NSString*)lastname;
- (BOOL)doBidirectionalSubstringMatch:(NSString*)one andTwo:(NSString*)two;

@end
