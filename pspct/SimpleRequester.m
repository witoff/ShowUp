//
//  SimpleRequester.m
//  pspct
//
//  Created by Robert Witoff on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SimpleRequester.h"

@implementation SimpleRequester

@synthesize url;

-(id)initWithUrl:(NSString*)request_url
{
    self = [super init];
    if (self)
    {
        self.url = request_url;
    }
    return self;
}

- (void)getJsonAsynchWithCompletionHandler:(void (^)(NSDictionary *, NSError *))completionBlock
{
    
    // Create the connection
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    
    // Make an NSOperationQueue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setName:@"com.your.unique.queue.name"];
    
    // Send an asyncronous request on the queue
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        // If there was an error getting the data
        if (error) {
            NSLog(@"error");
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                completionBlock(nil, error);
            });
            return;
        }
        
        // Decode the data
        NSError *jsonError;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        // If there was an error decoding the JSON
        if (jsonError) {
            NSLog(@"JSON Error");            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
            });
            return;
        }
        
        // All looks fine, lets call the completion block with the response data
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            completionBlock(responseDict, nil);
        });
    }];
}


@end
