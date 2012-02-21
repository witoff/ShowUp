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
#import "ScanAddressBook.h"
#import "SimpleRequester.h"

@implementation FriendTableVc

@synthesize listId, friends, friends_hidden, listName, listType, selected;

#pragma mark - init

- (id)initWithListId:(NSString*)identifier andListName:(NSString*)name andListType:(NSString*)type
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.listId = identifier;
        self.listName = name;
        self.listType = type;
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                        style:UIBarButtonItemStyleDone target:self action:@selector(sendMessage:)];
        
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)request:(FBRequest *)request didLoad:(id)result
{
    
    NSMutableArray* newFriends = [result objectForKey:@"data"];

    NSString *selectedString = nil;
    if (newFriends.count>10)
        selectedString = @"NO";
    else
        selectedString = @"YES";
    
    NSLog(@"type: %@", self.listType);
    if ([self.listType isEqualToString:@"family"])
    {
        NSLog(@"we have a family");
        [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Mom",@"name", nil]];
        [newFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Dad",@"name", nil]];
    }
    
    BOOL hasChanges = NO;
    for (NSDictionary* nf in newFriends) {
        bool isFound = NO;
        NSString* new_id = [nf objectForKey:@"id"];
        for (NSDictionary* friend in self.friends) {
            if ([new_id isEqualToString:[friend objectForKey:@"id"]])
            {
                isFound = YES;
                break;
            }
        }
        if (!isFound)
            for (NSDictionary* friend in self.friends_hidden) {
                if ([new_id isEqualToString:[friend objectForKey:@"id"]])
                {
                    isFound = YES;
                    break;
                }  
            }
        if (isFound)
            continue;
        hasChanges=YES;
        [self.friends addObject:nf];
        [self.selected addObject:selectedString];
    }
    
    //TODO: Handle if a user has been deleted from a group on Facebook
    
    if (hasChanges)
        [self.tableView reloadData];
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
    
    
    NSDictionary *list = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = [list objectForKey:@"name"];
    if ([[self.selected objectAtIndex:indexPath.row] isEqualToString:@"YES"])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selection found");
    
    if ([[self.selected objectAtIndex:indexPath.row] isEqualToString:@"YES"])
    {
        [self.selected replaceObjectAtIndex:indexPath.row withObject:@"NO"];
        NSLog(@"marked no");
    }
    else
    {
        NSLog(@"current: %@", [self.selected objectAtIndex:indexPath.row]);
        [self.selected replaceObjectAtIndex:indexPath.row withObject:@"YES"];
        NSLog(@"marked yes");
    }
    
    [self.tableView reloadData];

}

- (IBAction)sendMessage:(id)sender
{
    
    MFMessageComposeViewController *messageVc = [[MFMessageComposeViewController alloc] init];
    
    messageVc.messageComposeDelegate = self;
    
    NSMutableArray *recipients = [[NSMutableArray alloc] initWithCapacity:5];
    //get last name
    ScanAddressBook *addressBook = [[ScanAddressBook alloc] init];
    for (int i=0; i<self.selected.count; i++) {
        
        if ([[self.selected objectAtIndex:i] isEqualToString:@"NO"])
            continue;
        
        NSString *fullname = [[self.friends objectAtIndex:i] objectForKey:@"name"];
        NSArray *components = [fullname componentsSeparatedByString:@" "];
    
        NSString *lastname = nil;
        if (components.count>1)
            lastname = [components objectAtIndex:components.count-1];
        NSString* firstname = [components objectAtIndex:0];

        
    
        //get number
        NSString *number = [addressBook simpleSearch:firstname andLastName:lastname];
        if (number)
            [recipients addObject:number];
    }
        
    messageVc.recipients = recipients;
    messageVc.body = @"Be right there!";
    
    //This check is late in the message so debug info is written to the log
    if (![MFMessageComposeViewController canSendText])
        return;
    
    [self presentViewController:messageVc animated:YES completion:nil];
    NSLog(@"shown");
}


-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"commit editing style");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.friends_hidden addObject:[self.friends objectAtIndex:indexPath.row]];
        [self.friends removeObjectAtIndex:indexPath.row];
        [self.selected removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)loadData
{
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
        self.selected = [dict objectForKey:@"selected"];
        if (!self.selected)
            self.selected = [[NSMutableArray alloc] initWithCapacity:5];
    }
    else
    {
        NSLog(@"NO DATA TO LOAD, INITIALIZING WITH EMPTY DATA");
        self.friends = [[NSMutableArray alloc] initWithCapacity:11];
        self.friends_hidden = [[NSMutableArray alloc] initWithCapacity:5];
        self.selected = [[NSMutableArray alloc] initWithCapacity:11];
    }
}

-(void)saveData
{
    NSLog(@"saving data");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.listId];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.friends, @"friends", self.friends_hidden, @"friends_hidden", self.selected, @"selected", nil];
    if (![dict writeToFile:filePath atomically:YES])
        NSLog(@":: There was an error saving your data!!");
}

@end
