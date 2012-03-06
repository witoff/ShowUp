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

@interface FriendTableVc (hidden)

-(IBAction)showTemplateTable:(id)sender;
-(IBAction)showMissingContact:(id)sender;

- (void)loadData;
- (void)saveData;

-(NSArray*)getSelectedRecipients;

- (IBAction)sendSms:(id)sender;


@end


@implementation FriendTableVc

@synthesize listId, friends, friends_hidden, listName, listType, btnMessage, selected, imgMissing;

#pragma mark - init

- (id)initWithListId:(NSString*)identifier andListName:(NSString*)name andListType:(NSString*)type
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.listId = identifier;
        self.listName = name;
        self.listType = type;
        
        //Add Message Button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        btn.frame = CGRectMake(0, 0, 44, 44);
        
        //Images
        [btn setImage:[UIImage imageNamed:@"286-speechbubble-white"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"286-speechbubble"] forState:UIControlStateHighlighted];
        
        //Gestures
        [btn addTarget:self action:@selector(showTemplateTable:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sendSms:)];
        [btn addGestureRecognizer:recognizer];
        self.btnMessage = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        self.navigationItem.rightBarButtonItem = btnMessage;
    }
    return self;
}

#pragma mark - facebook

-(void)request:(FBRequest *)request didLoad:(id)result
{
    NSMutableArray* newFriends = [result objectForKey:@"data"];
    
    NSNumber *isSelected = [NSNumber numberWithBool:!(newFriends.count>10)];
    
    NSLog(@"type: %@", self.listType);
    //Auto add some members if the list is new
    if ([self.listType isEqualToString:@"family"] && self.friends.count==0)
    {
        NSLog(@"we have a family");
        [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Mom",@"name", @"Mom", @"id", nil]];
        [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Dad",@"name", @"Dad", @"id", nil]];
        [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Sister",@"name", @"Sister", @"id", nil]];
        [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Brother",@"name", @"Brother", @"id", nil]];
    }
    
    NSMutableDictionary *selected_unmatched = [[NSMutableDictionary alloc] initWithCapacity:11];
    NSMutableArray *friends_unmatched = [[NSMutableArray alloc] initWithCapacity:11];
    
    BOOL hasChanges = NO;
    for (NSDictionary* nf in newFriends) {
        
        bool isFound = NO;
        NSString* new_key = [nf objectForKey:@"id"];
        
        for (FbContact* fbContact in self.friends) {
            if ([fbContact.key isEqualToString:new_key])
            {
                isFound = YES;
                break;
            }
        }
        if (!isFound)
            for (FbContact* fbContact in self.friends_hidden) {
                if ([fbContact.key isEqualToString:new_key])
                {
                    isFound = YES;
                    break;
                }  
            }
        if (isFound)
            continue;
        hasChanges=YES;

        FbContact *newContact = [[FbContact alloc] init];
        newContact.name = [nf objectForKey:@"name"];
        newContact.key = [nf  objectForKey:@"id"];
        

        
        if (![newContact getBestAbContact] || ![[newContact getBestAbContact] getBestNumber])
        {
            [selected_unmatched setObject:[NSNumber numberWithBool:NO] forKey:newContact.key];
            [friends_unmatched addObject:newContact];
        }
        else
        {
            [self.selected setObject:isSelected forKey:newContact.key];
            [self.friends addObject:newContact];
        }
    }
    
    //TODO: Handle if a user has been deleted from a group on Facebook
    
    if (hasChanges)
    {
        [self.selected addEntriesFromDictionary:selected_unmatched];
        [self.friends addObjectsFromArray:friends_unmatched];
        [self.tableView reloadData];
    }
    NSLog(@"data merged");
    
    [self.tableView reloadData];
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
    NSString* endpoint = [NSString stringWithFormat:@"%@/members", self.listId, nil];
    NSLog(@"--asking for friends from: %@", endpoint);
    
    [appDelegate.facebook requestWithGraphPath:endpoint andDelegate:self];
    
    self.navigationItem.title = self.listName;
    
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
    [self saveData];
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
    if (!self.friends)
        return 0;
    if (section==0)
        return self.friends.count;
    return self.friends_hidden.count;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    FbContact *fbContact = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = fbContact.name;
    //cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", fbContact.name, [[fbContact getBestAbContact] getBestNumber]];
    
    if (![fbContact getBestAbContact] || ![[fbContact getBestAbContact] getBestNumber])
    {
        if (!self.imgMissing)
            self.imgMissing = [UIImage imageNamed:@"184-warning"];
        
        cell.imageView.image = self.imgMissing;
    }
    else
        cell.imageView.image = nil;
    
    if ([[self.selected objectForKey:fbContact.key] boolValue])
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
        [self saveData];
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
    
    FbContact *contact = [self.friends objectAtIndex:indexPath.row];
    

    //Toggle selection
    BOOL isSelected = [[selected objectForKey:contact.key] boolValue];
    [selected setObject:[NSNumber numberWithBool:!isSelected] forKey:contact.key];
    
    [self.tableView reloadData];
    
}

#pragma mark - custom methods

-(NSArray*)getSelectedRecipients
{
    NSMutableArray *recipients = [[NSMutableArray alloc] initWithCapacity:5];
    //get last name
    for (FbContact *friend in self.friends) {
        
        if (![[self.selected valueForKey:friend.key] boolValue])
            continue;
        
        //get number
        AbContact *contact = [friend getBestAbContact];
        
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
        [self.friends_hidden addObject:[self.friends objectAtIndex:indexPath.row]];
        [self.friends removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    NSDictionary *obj = [self.friends objectAtIndex:fromIndexPath.row];
    [self.friends removeObjectAtIndex:fromIndexPath.row];
    [self.friends insertObject:obj atIndex:toIndexPath.row];
    
    NSLog(@"cell was moved");
}


-(void)loadData
{
    /*
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0];
     NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.listId];
     
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
     if (dict)
     {
     //Check for nils otherwise they can prematurely terminate the dictionary that's later saved
     self.friends = [dict objectForKey:@"friends"];
     if (!self.friends)
     self.friends = [[NSMutableArray alloc] initWithCapacity:5];
     self.friends_hidden = [dict objectForKey:@"friends_hidden"];
     if (!self.friends_hidden)
     self.friends_hidden = [[NSMutableArray alloc] initWithCapacity:5];
     }
     else
     */
    {
        NSLog(@"NO DATA TO LOAD, INITIALIZING WITH EMPTY DATA");
        self.friends = [[NSMutableArray alloc] initWithCapacity:12];
        self.friends_hidden = [[NSMutableArray alloc] initWithCapacity:5];
        self.selected = [[NSMutableDictionary alloc] initWithCapacity:17];
    }
}

-(void)saveData
{
    /*
     NSLog(@"saving data");
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectory = [paths objectAtIndex:0];
     NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.listId];
     
     NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.friends, @"friends", self.friends_hidden, @"friends_hidden", nil];
     if (![dict writeToFile:filePath atomically:YES])
     NSLog(@":: There was an error saving your data!!");
     */
}


@end
