//
//  ContactProvider.m
//  perspect calendar
//
//  Created by Robert Witoff on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactProvider.h"
#import "ContactProviderAb.h"

@implementation ContactProvider

- (NSArray*) getAllContacts
{
    //Override
    return nil;
}

+ (NSArray*)allcontacts {
    //Override
    return nil;
}

+ (void)setAllcontacts:(NSArray *)newContacts{
    //Override
}

+(void)invalidateContactList
{    
    //Override
}

static ContactProvider* _provider;

+(ContactProvider*)defaultProvider
{
    if (!_provider)
        _provider = [[ContactProviderAb alloc] init];
    
    return _provider;
}

+(void)setDefaultProvider:(ContactProvider*)provider
{
    _provider = provider;
}

@end
