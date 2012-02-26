//
//  PspctPredefinedMessageTableVc.h
//  pspct
//
//  Created by Robert Witoff on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TemplateTableVc : UITableViewController<UIAlertViewDelegate>
{
    NSMutableArray *messages;
}

@property (nonatomic, retain) NSMutableArray *messages;

-(void)loadTemplates;
-(IBAction)addTemplate:(id)sender;
-(void)saveData;

@end
