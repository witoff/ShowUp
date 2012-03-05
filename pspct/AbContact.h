//
//  Contact.h
//  pspct
//
//  Created by Robert Witoff on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface AbContact : NSObject
{
    NSNumber *key;
    NSString *firstname;
    NSString *lastname;
    UIImage *image;
    NSMutableArray *numbers;
    NSString *email;

    NSNumber *matchConfidence;
}

@property (nonatomic, retain) NSNumber *key;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSMutableArray *numbers;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSNumber *matchConfidence;

+ (AbContact*)contactWithAbContactKey:(NSNumber*)key;
+ (AbContact*)contactWithRecordRef:(ABRecordRef)ref;

-(NSString*)getBestNumber;
-(NSString*)getFullname;

@end