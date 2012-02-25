//
//  Contact.m
//  pspct
//
//  Created by Robert Witoff on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@synthesize identifier, lastname, firstname, image, numbers, email, matchConfidence;

-(id)init
{
    self = [super init];
    if (self)
    {
        self.numbers= [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

-(NSString*)getBestNumber
{
    NSLog(@"getBestNumber");
    
    if (self.numbers == nil)
        return nil;
    if (self.numbers.count==0)
        return nil;
    
    NSString *bestNumber = nil;
    NSString *bestLabel = nil;
    for (NSDictionary *numberPair in self.numbers) {
        NSString *label = [[numberPair objectForKey:@"label"] lowercaseString];
        NSString *number = [numberPair objectForKey:@"number"] ; 
        
        //favor iphone
        if ([label isEqualToString:@"iphone"])
        {
            bestLabel = label;
            bestNumber = number;
            break;
        }
        
        if ([label isEqualToString:@"mobile"])
        {
            bestLabel = label;
            bestNumber = number;
        }
        else if ([label isEqualToString:@"home"] && ![bestLabel isEqualToString:@"mobile"])
        {
            bestLabel = label;
            bestNumber = number;
        }
        else if (!bestLabel)
        {
            bestLabel = label;
            bestNumber = number;
        }
        
    }
    return bestNumber;
    
}

-(NSString*)getFullname
{
    if (firstname && lastname)
        return [NSString stringWithFormat:@"%@ %@", firstname, lastname];
    return @"";
}

@end
