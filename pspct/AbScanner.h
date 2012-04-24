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
    NSString *firstname;
    NSString *lastname;
    
    ModelFbUser *fbUser;
}

@property (nonatomic, retain) ModelFbUser *fbUser;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;

+(void)invalidateContactList;

- (id)initWithFbUser:(ModelFbUser*)user;
- (id)initWithFirstname:(NSString*)first andLastname:(NSString*)last;

- (AbContact*) simpleSearch;
- (AbContact*) getMatchingAbContact;



@end
