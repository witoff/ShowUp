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
#import "MixpanelAPI.h"
#import "Constants.h"

@interface FriendListTableVc (hidden)

+(NSString*)getSaveFilePath;

-(IBAction)editOrder:(id)sender;

-(void)fbDidLogin:(NSNotification*)notification;
-(void)fbDidLogout:(NSNotification*)notification;
-(void)dataUpdated:(NSNotification*)notification;
@end

@implementation FriendListTableVc

@synthesize friendLists, friendLists_hidden;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"FLTVC :: initWithCoder");
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fbDidLogin:) 
                                                     name:EVENT_FB_LOGIN
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fbDidLogout:) 
                                                     name:EVENT_FB_LOGOUT
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dataUpdated:) 
                                                     name:EVENT_FRIENDLIST_SHOW_HIDDEN
                                                   object:nil];
    }
    return self;
}

-(void)fbDidLogin:(NSNotification*)notification
{
    NSLog(@"didLogin friend list: %@", notification.name);
    
    PspctAppDelegate *appDelegate = (PspctAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.facebook isSessionValid])
        [appDelegate.facebook requestWithGraphPath:@"me/friendlists" andDelegate:self];
    else
        NSLog(@"Session was not valid");
    
    [self performSelectorInBackground:@selector(preloadMvc) withObject:nil];
    
    
}

-(void)fbDidLogout:(NSNotification*)notification
{
    self.friendLists = nil;
    self.friendLists_hidden = nil;
    [self.tableView reloadData];
}
-(void)dataUpdated:(NSNotification *)notification
{
    NSLog(@"data updated");
    [self loadData];
    [self.tableView reloadData];
}

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
    {
        [self saveData];
        [self.tableView reloadData];
    }
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

+(NSString*)getSaveFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:FILENAME_FRIEND_LIST];
    return filePath;
}

-(void)loadData
{    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[FriendListTableVc getSaveFilePath]];
    if (dict)
    {
        self.friendLists = [dict objectForKey:FILE_FRIENDLISTS];
        self.friendLists_hidden = [dict objectForKey:FILE_FRIENDLISTS_HIDDEN];            
    }

    if (!self.friendLists)
        self.friendLists = [[NSMutableArray alloc] initWithCapacity:11];
    if (!self.friendLists_hidden)
        self.friendLists_hidden = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSLog(@"loaded data.  lists: %i, hidden: %i", self.friendLists.count, self.friendLists_hidden.count);
}

-(void)saveData
{
    NSLog(@"saving data");
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.friendLists, FILE_FRIENDLISTS, self.friendLists_hidden, FILE_FRIENDLISTS_HIDDEN, nil];
    [dict writeToFile:[FriendListTableVc getSaveFilePath] atomically:YES];
    
    NSLog(@"loaded data.  lists: %i, hidden: %i", self.friendLists.count, self.friendLists_hidden.count);
}

+(void)deleteData
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSError *error;
    if ([fileMgr removeItemAtPath:[FriendListTableVc getSaveFilePath] error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
}

+(void) showHiddenLists
{
    NSLog(@"showHiddenLists");
    NSMutableDictionary *loaded = [NSMutableDictionary dictionaryWithContentsOfFile:[FriendListTableVc getSaveFilePath]];
    if (loaded)
    {
        NSMutableArray *friendLists =  [loaded objectForKey:@"friendLists"];
        NSMutableArray *friendLists_hidden =  [loaded objectForKey:@"friendLists_hidden"];
        [friendLists addObjectsFromArray:friendLists_hidden];
        
        NSMutableDictionary *toSave = [NSMutableDictionary dictionaryWithObjectsAndKeys:friendLists, FILE_FRIENDLISTS, nil];
        [toSave writeToFile:[FriendListTableVc getSaveFilePath] atomically:YES];        
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_FRIENDLIST_SHOW_HIDDEN object:nil];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [self loadData];
    
    [self fbDidLogin:nil];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
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
    [[MixpanelAPI sharedAPI] track:@"opened list"]; 
    
    NSDictionary *list = [self.friendLists objectAtIndex:indexPath.row];
    [self setEditing:NO];
    
    FriendTableVc *friendTable = [[FriendTableVc alloc] initWithListId:[list objectForKey:@"id"] andListName:[list objectForKey:@"name"] andListType:[list objectForKey:@"list_type"]];
    [self.navigationController pushViewController:friendTable animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //using arc so don't need to call [super dealloc]
}


@end
