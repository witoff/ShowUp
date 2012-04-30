//
//  ContactTextParser.h
//  perspect calendar
//
//  Created by Robert Witoff on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactProvider.h"

@interface ContactTextParser : NSObject
{
    NSString *raw_text;
    
@private
    NSMutableArray* _contacts;
    BOOL isParsed;
}

@property (nonatomic, retain) NSString *raw_text;
@property (nonatomic, retain) NSMutableArray *_contacts;

-(id)initWithText:(NSString*)text;
-(id)initWithText:(NSString*)text andContactProvider:(ContactProvider*)provider;

-(NSArray*)getContacts;

@end
