//
//  EventParticipantMatcher.h
//  perspect calendar
//
//  Created by Robert Witoff on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbContact.h"

@interface FullNameParser : NSObject
{
    NSString *raw_name;
    
    @private
    NSString *_firstname;
    NSString *_lastname;
    AbContact *contact;
    BOOL isParsed;
}

@property (nonatomic, retain) NSString *raw_name;

@property (nonatomic, retain) NSString *_firstname;
@property (nonatomic, retain) NSString *_lastname;
@property (nonatomic, retain) AbContact *contact;

-(id)initWithName:(NSString*)_name;

-(NSString*)getFirstname;
-(NSString*)getLastname;

@end