//
//  FbContact.h
//  pspct
//
//  Created by Robert Witoff on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbContact.h"

@interface FbContact : NSObject
{
    /* serializable */
    NSString *key;
    NSString *name;
    
    NSString *_firstname;
    NSString *_lastname;
    
    NSNumber *hasSearchedForAbMatch;
    NSNumber *abContactMatchKey;
    
    /* inferred */
    AbContact *abContactMatch;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *name;

@property (readonly) NSString* firstname;
@property (readonly) NSString* lastname;

@property (nonatomic, retain) NSNumber *hasSearchedForAbMatch;
@property (nonatomic, retain) NSNumber *abContactMatchKey;
@property (nonatomic, retain) AbContact *abContactMatch;

-(AbContact*)getBestAbContact;

@end
