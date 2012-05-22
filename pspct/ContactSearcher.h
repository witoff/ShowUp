//
//  ContactScanner.h
//  perspect calendar
//
//  Created by Robert Witoff on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "AbContact.h"
#import "ModelFbUser.h"
#import "ContactProvider.h"

@interface ContactSearcher : NSObject
{
    @private
    NSString *_firstname;
    NSString *_lastname;
    ContactProvider* _provider;
    ModelFbUser *_fbUser;

    
}

@property (nonatomic, retain) ContactProvider *_provider;
@property (nonatomic, retain) ModelFbUser *_fbUser;
@property (nonatomic, retain) NSString *_firstname;
@property (nonatomic, retain) NSString *_lastname;

- (id)initWithContactProvider:(ContactProvider*)provider;
- (id)initWithContactProvider:(ContactProvider*)provider andFbUser:(ModelFbUser*)user;
- (id)initWithContactProvider:(ContactProvider*)provider andFirstname:(NSString*)first andLastname:(NSString*)last;

- (AbContact*) simpleSearch;
- (AbContact*) getMatchingAbContact;

@end
