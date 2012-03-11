//
//  PspctFriendTableVc.m
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendTableVc.h"
#import "PspctAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "AbScanner.h"
#import "SimpleRequester.h"
#import "TemplateTableVc.h"
#import "AbContact.h"
#import "FbContact.h"
#import "ModelGroup.h"
#import "ModelFbList.h"
#import "ModelGroupUserEntry.h"
#import "ModelFbUser.h"
#import "ModelAbkContactMatch.h"

@interface FriendTableVc (hidden)

-(IBAction)showTemplateTable:(id)sender;
-(IBAction)showMissingContact:(id)sender;

- (void)loadData;

-(NSArray*)getSelectedRecipients;

- (IBAction)sendSms:(id)sender;

@end


@implementation FriendTableVc

@synthesize friends, btnMessage, imgMissing, group;

#pragma mark - init

- (id)initWithGroup:(ModelGroup*)aGroup
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.group = aGroup;
        
        //Add Message Button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        btn.frame = CGRectMake(0, 0, 44, 44);
        
        //Images
        [btn setImage:[UIImage imageNamed:@"286-speechbubble-white"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"286-speechbubble"] forState:UIControlStateHighlighted];
        
        //Gestures
        [btn addTarget:self action:@selector(showTemplateTable:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sendSms:)];
        recognizer.minimumPressDuration = .3;
        [btn addGestureRecognizer:recognizer];
        self.btnMessage = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        self.navigationItem.rightBarButtonItem = btnMessage;
    }
    return self;
}

#pragma mark - facebook

-(void)request:(FBRequest *)request didLoad:(id)result
{
    NSMutableArray* newUsers = [result objectForKey:@"data"];
    
    if (group.class == [ModelFbList class])
    {
        /*TODO: Make this work with the new objects
         
         ModelFbList *list = (ModelFbList*)group;
         NSLog(@"type: %@", list.list_type);
         //Auto add some members if the list is new
         if ([list.list_type isEqualToString:@"family"] && self.friends.count==0)
         {
         NSLog(@"we have a family");
         [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Mom",@"name", @"Mom", @"id", nil]];
         [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Dad",@"name", @"Dad", @"id", nil]];
         [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Sister",@"name", @"Sister", @"id", nil]];
         [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Brother",@"name", @"Brother", @"id", nil]];
         }
         */
    }
    
    int n_changes = 0;
    for (NSDictionary* nu in newUsers) {
        
        NSString* new_key = [nu objectForKey:@"id"];
        
        //
        // DOES USER EXIST
        //
        ModelFbUser *user = [ModelFbUser getUserWithFbKey:new_key];
        
        /*
         NSArray *allUsers = [ModelFbUser getAllUsers];
         for (ModelFbUser *u in allUsers)
         {
         if ([u.fb_key isEqualToString:new_key])
         NSLog(@"LIARS id: %@", u.fb_key);
         }
         NSLog(@"all users: %i", allUsers.count);
         */
        
        if (!user)
        {
            //user doesn't exist, neeeds to be created
            NSLog(@"user doesn't exist");
            user = [ModelFbUser insertUserFromFbBlob:nu];
            
            ModelGroupUserEntry *entry = [ModelGroupUserEntry insertNewObject];
            entry.user = user;
            entry.group = self.group;
            
            if (user.adbk_match)
                entry.order = [NSNumber numberWithInt: 0];
            else
                entry.order = [NSNumber numberWithInt: self.group.users.count];
            
            n_changes++;        
            continue;
        }
        
        //
        // IS USER CAPTURED IN THIS LIST?
        //
        bool isFound = NO;        
        for (ModelGroupUserEntry *entry in group.users) {
            if ([entry.user.fb_key isEqualToString:new_key])
            {
                isFound = YES;                
                break;
            }
        }
        if (!isFound)
        {
            NSLog(@"user exists, but wasn't found in this group.");
            ModelGroupUserEntry *entry = [ModelGroupUserEntry insertNewObject];
            entry.user = user;
            entry.group = self.group;
            entry.is_visible = [NSNumber numberWithBool:YES];
            
            if (user.adbk_match)
                entry.order = [NSNumber numberWithInt: 0];
            else
                entry.order = [NSNumber numberWithInt: self.group.users.count];
            
            n_changes++;        
        }
    }
    
    //TODO: Handle if a user has been deleted from a group on Facebook
    
    if (n_changes)
    {
        [self loadData];
        [self updateRowOrder];
        [self.tableView reloadData];
    }
    NSLog(@"Friend data loaded.  %i changes.", n_changes);
}
-(void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Error in FB Request");
    //error handling in here
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self loadData];
    
    PspctAppDelegate *appDelegate = (PspctAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString* endpoint = [NSString stringWithFormat:@"%@/members", self.group.fb_key, nil];
    NSLog(@"--asking for friends from: %@", endpoint);
    
    [appDelegate.facebook requestWithGraphPath:endpoint andDelegate:self];
    
    self.navigationItem.title = self.group.name;
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
}

- (void)viewDidUnload
{
    if (!self.friends || self.friends.count==0)
    {
        //Need to cancel any unsent FB requests so dumb FB api doesnt return to a non-existend VC
        PspctAppDelegate *appDelegate = (PspctAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate.facebook cancelPendingRequest];
    }
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.friends && section==0)
        return self.friends.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    ModelGroupUserEntry *entry = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = entry.user.name;
    //cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", fbContact.name, [[fbContact getBestAbContact] getBestNumber]];
    if (!entry.user.adbk_match) // || ![[entry.user.adbk_match getAbContact] getBestNumber]
    {
        if (!self.imgMissing)
            self.imgMissing = [UIImage imageNamed:@"184-warning"];
        
        cell.imageView.image = self.imgMissing;
    }
    else
        cell.imageView.image = nil;
    
    if (entry.is_selected.boolValue)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    UILongPressGestureRecognizer *recognizer  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editOrder:)];
    [cell addGestureRecognizer:recognizer];
    
    
    return cell;
    
}

-(IBAction)showMissingContact:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Number" message:@"A match could not be found for this person" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

-(IBAction)editOrder:(id)sender
{
    self.navigationItem.rightBarButtonItem = self.editButtonItem;    
    [self setEditing:YES animated:YES];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (!editing)
    {
        self.navigationItem.rightBarButtonItem = btnMessage;
    }
    [super setEditing:editing animated:animated];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.imageView.image)
    {
        [self showMissingContact:cell];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    NSLog(@"selection found");
    
    ModelGroupUserEntry *entry = [self.friends objectAtIndex:indexPath.row];
    
    
    //Toggle selection
    BOOL isSelected = entry.is_selected.boolValue ;
    entry.is_selected = [NSNumber numberWithBool:!isSelected];
    
    [self.tableView reloadData];
    
}

#pragma mark - custom methods

-(NSArray*)getSelectedRecipients
{
    NSMutableArray *recipients = [[NSMutableArray alloc] initWithCapacity:5];
    //get last name
    for (ModelGroupUserEntry *entry in self.friends) {
        
        if (!entry.is_selected.boolValue)
            continue;
        
        //get number
        AbContact *contact = [entry.user.adbk_match getAbContact];
        
        NSString* number = [contact getBestNumber];
        
        NSLog(@"Confidence for: %@ is: %@", [contact getFullname], contact.matchConfidence);
        
        if (number)
            [recipients addObject:number];
    }
    return recipients;
}

- (IBAction)sendSms:(id)sender
{
    [self sendSmsWithMessage:@""];
}
- (void)sendSmsWithMessage:(NSString*)message
{
    MFMessageComposeViewController *messageVc = [[MFMessageComposeViewController alloc] init];
    
    messageVc.messageComposeDelegate = self;
    
    messageVc.recipients = [self getSelectedRecipients];
    messageVc.body = message;
    
    //This check is late in the message so debug info is written to the log
    if (![MFMessageComposeViewController canSendText])
        return;
    
    NSNumber *n_recipients = [NSNumber numberWithInt:messageVc.recipients.count];
    [[MixpanelAPI sharedAPI] track:@"sending message" properties:[NSDictionary dictionaryWithObject:n_recipients forKey:@"n_recipients"]];
    
    
    [self presentViewController:messageVc animated:YES completion:nil];
    NSLog(@"shown");
}



-(IBAction)showTemplateTable:(id)sender
{
    [[MixpanelAPI sharedAPI] track:@"opened template table"]; 
    NSLog(@"sendPredefinedMessage");
    if (self.navigationController.viewControllers.count==2)
    {
        NSLog(@"Pushing VC");
        TemplateTableVc *pmvc = [[TemplateTableVc alloc] init];
        [self.navigationController pushViewController:pmvc animated:YES];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString* resultString;
    switch (result) {
        case MessageComposeResultCancelled:
            resultString = @"cancelled";
            break;
        case MessageComposeResultFailed:
            resultString = @"failed";            
            break;
        case MessageComposeResultSent:
            resultString = @"sent";
            break;
        default:
            resultString = @"";
            break;
    }
    [[MixpanelAPI sharedAPI] track:@"message sent" properties:[NSDictionary dictionaryWithObjectsAndKeys:resultString, @"result", nil]];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Hide";
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"commit editing style");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        ModelGroupUserEntry *entry = [self.friends objectAtIndex:indexPath.row];
        entry.is_visible = [NSNumber numberWithBool:NO];
        [self.friends removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateRowOrder];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    NSDictionary *obj = [self.friends objectAtIndex:fromIndexPath.row];
    [self.friends removeObjectAtIndex:fromIndexPath.row];
    [self.friends insertObject:obj atIndex:toIndexPath.row];
    
    [self updateRowOrder];
    
    NSLog(@"cell was moved");
}


-(void)loadData
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order"
                                                                   ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.group.users.allObjects sortedArrayUsingDescriptors:sortDescriptors];
    
    self.friends = [NSMutableArray arrayWithArray: sortedArray];
}

-(void)updateRowOrder
{
    for (int i=0; i<self.friends.count; i++) {
        ModelGroupUserEntry *entry = [self.friends objectAtIndex:i];
        entry.order = [NSNumber numberWithInt:i];        
    }
}

@end
