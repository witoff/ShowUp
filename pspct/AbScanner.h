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
#import "ModelFbUser.h"

@interface AbScanner : NSObject
{
    ModelFbUser* fbUser;
}

@property (nonatomic, retain) ModelFbUser *fbUser;

+(void)invalidateContactList;

- (id)initWithFbUser:(ModelFbUser*)user;

- (AbContact*) simpleSearch;
- (AbContact*) getMatchingAbContact;



@end
