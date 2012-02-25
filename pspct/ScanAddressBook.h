//
//  ScanAddressBook.h
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "Contact.h"

@interface ScanAddressBook : NSObject
{

}

- (Contact*) simpleSearch:(NSString*)firstname andLastName:(NSString*)lastname;
- (Contact*) search:(NSString*)firstname andLastName:(NSString*)lastname;
- (Contact*)getContactWithId:(NSNumber*)identifier;

+(void)invalidateContactList;

@end
