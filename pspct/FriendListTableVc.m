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
#import "ModelGroup.h"
#import "ModelFbList.h"
#import "ModelFbGroup.h"

NSString * const EVENT_FRIENDLIST_SHOW_HIDDEN = @"showHiddenLists";

@interface FriendListTableVc (hidden)

-(IBAction)editOrder:(id)sender;

-(void)fbDidLogin:(NSNotification*)notification;
-(void)fbDidLogout:(NSNotification*)notification;
-(void)dataUpdated:(NSNotification*)notification;
-(void)updateRowOrder;

@end

@implementation FriendListTableVc

@synthesize groups, lists;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"FriendListTableVc :: initWithCoder");
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
    {
        [appDelegate.facebook requestWithGraphPath:@"me/friendlists" andDelegate:self];
        [appDelegate.facebook requestWithGraphPath:@"me/groups" andDelegate:self];
    }
    else
        NSLog(@"Session was not valid");
    
    [self performSelectorInBackground:@selector(preloadMvc) withObject:nil];
    
    
}

-(void)fbDidLogout:(NSNotification*)notification
{
    self.groups = nil;
    self.lists = nil;
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
    NSLog(@"facebook response did load");
    int n_changes = 0;
    if ([request.url containsString:@"/friendlists"])
    {
        NSLog(@"...friendlists");
        n_changes = [self processFbResponse:result withModel:[ModelFbList class]];
    }
    else if ([request.url containsString:@"/groups"])
    {
        NSLog(@"...groups");     
        n_changes = [self processFbResponse:result withModel:[ModelFbGroup class]];        
    }
    
    NSLog(@"n_changes: %i", n_changes);
    if (n_changes)
    {
        
        [self loadData];
        [self.tableView reloadData];
        [self updateRowOrder];
    }
    
}

-(int)processFbResponse:(id)result withModel:(Class)groupType 
{
    NSArray *savedGroups = [groupType getAll];
    
    int n_changes=0;
    NSMutableArray *newGroups = [result objectForKey:@"data"];
    
    for (NSDictionary* newGroup in newGroups) {
        
        bool isFound = NO;
        NSString* new_id = [newGroup objectForKey:@"id"];
        
        for (ModelGroup* group in savedGroups) {
            if ([new_id isEqualToString:group.fb_id])
            {
                isFound = YES;
                if (![group.name isEqualToString:[newGroup objectForKey:@"name"]])
                {
                    group.name = [newGroup objectForKey:@"name"];
                    n_changes++;
                }
                break;
            }
        }
        if (isFound)
            continue;
        
        NSLog(@"Group not found: %@", [newGroup objectForKey:@"name"]);
        //Add new obj
        n_changes++;
        [groupType groupFromFbBlob:newGroup];
        

    }
    if (n_changes)
        //TODO: save????
        
        NSLog(@"%i changes found", n_changes);
    return n_changes;
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
    NSLog(@"loading data");
    
    self.groups = [[NSMutableArray alloc] initWithArray:[ModelFbGroup getAllVisible]];
    self.lists = [[NSMutableArray alloc] initWithArray:[ModelFbList getAllVisible]];
    
    NSLog(@"loaded data.  lists: %i, groups: %i", self.groups.count, self.lists.count);
}

+(void) showHiddenLists
{
    //Get Context
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    NSArray* all = [ModelGroup getAll];
    for (ModelGroup *group in all)
    {
        group.is_visible = [NSNumber numberWithBool:YES];
    }
    NSError *error;
    [context save:&error];
    
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if (section==0 && self.groups)
        return self.groups.count;
    if (section==1 && self.lists)
        return self.lists.count;
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
    
    ModelGroup *group;    
    if (indexPath.section==0)
        group = [self.groups objectAtIndex:indexPath.row];
    else
        group = [self.lists objectAtIndex:indexPath.row];
    
    cell.textLabel.text = group.name;
    
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
        ModelGroup *obj = [self getModelGroupForIndexPath:indexPath];
        obj.is_visible = [NSNumber numberWithBool:NO];
        
        [[self getDataArrayForIndexPath:indexPath] removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self updateRowOrder];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(ModelGroup*)getModelGroupForIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section==0 && self.groups)
        return [self.groups objectAtIndex:indexPath.row];
    if (indexPath.section==1 && self.lists)
        return [self.lists objectAtIndex:indexPath.row];
    return nil;
}
-(NSMutableArray*)getDataArrayForIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section==0)
        return self.groups;
    if (indexPath.section==1)
        return self.lists;
    return nil;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath.section != toIndexPath.section)
        return;
    
    ModelGroup *obj = [self getModelGroupForIndexPath:fromIndexPath];
    NSMutableArray *data = [self getDataArrayForIndexPath:fromIndexPath];
    [data removeObjectAtIndex:fromIndexPath.row];
    [data insertObject:obj atIndex:toIndexPath.row];
    
    [self updateRowOrder];
    
    NSLog(@"cell was moved");
}

-(void)updateRowOrder
{
    for (int i=0; i<self.groups.count; i++) {
        ModelGroup *obj = [self.groups objectAtIndex:i];
        obj.order = [NSNumber numberWithInt:i];
    }
    for (int i=0; i<self.lists.count; i++) {
        ModelGroup *obj = [self.lists objectAtIndex:i];
        obj.order = [NSNumber numberWithInt:i];
    }
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
    
    ModelGroup *group = [self getModelGroupForIndexPath:indexPath];
    [self setEditing:NO];
    
    //TODO: The model object should know what kind of table VC to show
    FriendTableVc *friendTable;
    if (group.class == [ModelFbList class])
        friendTable= [[FriendTableVc alloc] initWithListId:group.fb_id andListName:group.name andListType:[group valueForKey:@"list_type"]];
    else
        friendTable= [[FriendTableVc alloc] initWithListId:group.fb_id andListName:group.name andListType:@"friends"];
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
