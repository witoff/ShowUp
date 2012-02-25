//
//  Contact.h
//  pspct
//
//  Created by Robert Witoff on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject
{
    NSNumber *identifier;
    NSString *firstname;
    NSString *lastname;
    UIImage *image;
    NSMutableArray *numbers;
    NSString *email;

    NSNumber *matchConfidence;
}

@property (nonatomic, retain) NSNumber *identifier;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSMutableArray *numbers;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSNumber *matchConfidence;

-(NSString*)getBestNumber;
-(NSString*)getFullname;

@end
