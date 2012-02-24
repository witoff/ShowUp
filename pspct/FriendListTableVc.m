//
//  PspctFriendLists.m
//  pspct
//
//  Created by Robert Witoff on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendListTableVc.h"
#import "PspctAppDelegate.h"
#import "FriendTableVc.h"
#import <MessageUI/MessageUI.h>

@implementation FriendListTableVc

@synthesize friendLists, friendLists_hidden;

// FACEBOOK REQUEST METHODS
-(void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"facebook response received, merging data");
    
    //Merge new data with existing data
    BOOL hasChanges = NO;
    NSMutableArray *lists = [result objectForKey:@"data"];
    
    for (NSDictionary* new_fl in lists) {
        bool isFound = NO;
        NSString* new_id = [new_fl objectForKey:@"id"];
        for (NSDictionary* fl in self.friendLists) {
            if ([new_id isEqualToString:[fl objectForKey:@"id"]])
            {
                isFound = YES;
                break;
            }
        }
        if (!isFound)
            for (NSDictionary* fl in self.friendLists_hidden) {
                if ([new_id isEqualToString:[fl objectForKey:@"id"]])
                {
                    isFound = YES;
                    break;
                }  
            }
        if (isFound)
            continue;
        hasChanges=YES;
        [self.friendLists addObject:new_fl];
    }

    if (hasChanges)
        [self.tableView reloadData];
    NSLog(@"data merged");
}
-(void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"PspctFriendListTableVc :: Error in FB Request: %@", error.description);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in Facebook request" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)loadData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"friendLists.dat"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if (dict)
    {
        self.friendLists = [dict objectForKey:@"friendLists"];
        self.friendLists_hidden = [dict objectForKey:@"friendLists_hidden"];
    }
    else
    {
        self.friendLists = [[NSMutableArray alloc] initWithCapacity:11];
        self.friendLists_hidden = [[NSMutableArray alloc] initWithCapacity:5];
    }
}

-(void)saveData
{
    NSLog(@"saving data");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"friendLists.dat"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.friendLists, @"friendLists", self.friendLists_hidden, @"friendLists_hidden", nil];
    [dict writeToFile:filePath atomically:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;    
    [self loadData];
    
    PspctAppDelegate *appDelegate = (PspctAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.facebook isSessionValid])
        [appDelegate.facebook requestWithGraphPath:@"me/friendlists" andDelegate:self];
    else
        NSLog(@"Session was not valid");
    
    NSLog(@"preloading");
    [self performSelectorInBackground:@selector(preloadMvc) withObject:nil];
    NSLog(@"preloaded");
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

-(void) preloadMvc
{
    //verrry slow the first time this object is called.  preloading seems to help out a bit.
    NSLog(@"preloading mvc");
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageVc = [[MFMessageComposeViewController alloc] init];
        messageVc.body = @"blank text";
        NSLog(@"preloaded mvc with body: %@", messageVc.body);
    }
    
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

    // Return the number of rows in the section.
    if (self.friendLists)
        return self.friendLists.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    UILongPressGestureRecognizer *recognizer  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editOrder:)];
    [cell addGestureRecognizer:recognizer];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *list = [self.friendLists objectAtIndex:indexPath.row];
    cell.textLabel.text = [list objectForKey:@"name"];

    return cell;
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
        self.navigationItem.rightBarButtonItem = nil;
        [self saveData];
    }
    [super setEditing:editing animated:animated];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.friendLists_hidden addObject:[self.friendLists objectAtIndex:indexPath.row]];
        [self.friendLists removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSDictionary *obj = [self.friendLists objectAtIndex:fromIndexPath.row];
    [self.friendLists removeObjectAtIndex:fromIndexPath.row];
    [self.friendLists insertObject:obj atIndex:toIndexPath.row];
    
    NSLog(@"cell was moved");
}


-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Hide";
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *list = [self.friendLists objectAtIndex:indexPath.row];
    [self setEditing:NO];
    
    FriendTableVc *friendTable = [[FriendTableVc alloc] initWithListId:[list objectForKey:@"id"] andListName:[list objectForKey:@"name"] andListType:[list objectForKey:@"list_type"]];
    [self.navigationController pushViewController:friendTable animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.;
}


@end
