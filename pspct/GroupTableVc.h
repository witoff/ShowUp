//
//  PspctFriendLists.h
//  pspct
//
//  Created by Robert Witoff on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "ModelGroup.h"

@interface GroupTableVc : UITableViewController<FBRequestDelegate>
{
    NSMutableArray* groups;
    NSMutableArray* lists;
}

@property (nonatomic, retain) NSMutableArray *groups;
@property (nonatomic, retain) NSMutableArray *lists;

+(void) showHiddenLists;

-(void) loadData;

-(void) preloadMvc;

-(int)processFbResponse:(id)result withModel:(Class)groupType;

@end
