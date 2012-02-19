//
//  PspctPredefinedMessageTableVc.h
//  pspct
//
//  Created by Robert Witoff on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PspctPredefinedMessageTableVc : UITableViewController
{
    NSMutableArray *messages;
}

@property (nonatomic, retain) NSMutableArray *messages;

@end
