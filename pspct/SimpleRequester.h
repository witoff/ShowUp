//
//  SimpleRequester.h
//  pspct
//
//  Created by Robert Witoff on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleRequester : NSObject
{
    NSString* url;
}

@property(nonatomic, retain) NSString *url;


- (id)initWithUrl:(NSString*)request_url;
- (void)getJsonAsynchWithCompletionHandler:(void (^)(NSDictionary *, NSError *))completionBlock;

@end
