//
//  ScanAddressBook.h
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "AbContact.h"
#import "FbContact.h"

@interface AbScanner : NSObject
{
    FbContact* fbContact;
}

@property (nonatomic, retain) FbContact *fbContact;

+(void)invalidateContactList;

- (id)initWithFbContact:(FbContact*)fbContact;

- (AbContact*) simpleSearch;
- (AbContact*) getMatchingAbContact;



@end
