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

NSString * const EVENT_FRIENDLIST_SHOW_HIDDEN = @"showHiddenLists";

@interface FriendListTableVc (hidden)

-(IBAction)editOrder:(id)sender;

-(void)fbDidLogin:(NSNotification*)notification;
-(void)fbDidLogout:(NSNotification*)notification;
-(void)dataUpdated:(NSNotification*)notification;
-(void)updateRowOrder;

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

-(void)debugModel
{
    //
    // DEV CODE TO LEARN CORE DATA
    //
    
    //Get Context
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    
    //Creating a managed object
    NSManagedObject *newList = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:context];
    [newList setValue:@"test name" forKey:@"name"];
    NSError *error;
    //[context save:&error];
    

    //Get Entity
    NSEntityDescription *entityDesc = [NSEntityDescription    
                                       entityForName:@"List" inManagedObjectContext:context];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDesc];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", "John Smith"];
    [request setPredicate: pred];
    NSArray *matching_objects = [context executeFetchRequest:request error:&error]; ;
    for (NSManagedObject *obj in matching_objects)
    {
        NSLog(@"Found object: %@", [obj valueForKey:@"name"]);
    }
    
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
    int n_changes=0;
    NSMutableArray *lists = [result objectForKey:@"data"];
    
    for (NSDictionary* new_fl in lists) {
        bool isFound = NO;
        NSString* new_id = [new_fl objectForKey:@"id"];
        for (NSManagedObject* fl in self.friendLists) {
            if ([new_id isEqualToString:[fl valueForKey:@"id"]])
            {
                isFound = YES;
                break;
            }
        }
        if (!isFound)
            for (NSManagedObject* fl in self.friendLists_hidden) {
                if ([new_id isEqualToString:[fl valueForKey:@"id"]])
                {
                    isFound = YES;
                    break;
                }  
            }
        if (isFound)
            continue;
        n_changes++;
        
        NSManagedObject *obj = [self getNewList:new_fl];
        [self.friendLists addObject:obj];
    }

    NSLog(@"%i changes found", n_changes);    
    if (n_changes)
    {
        [self.tableView reloadData];
        [self updateRowOrder];
    }
    NSLog(@"data merged");
}
-(NSManagedObject*)getNewList:(NSDictionary*)fbListObj
{
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    
    //Creating a managed object
    NSManagedObject *newList = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:context];
    [newList setValue:[fbListObj objectForKey:@"id"] forKey:@"id"];
    [newList setValue:[fbListObj objectForKey:@"name"] forKey:@"name"];
    [newList setValue:[fbListObj objectForKey:@"list_type"] forKey:@"list_type"];
    [newList setValue:[NSNumber numberWithBool:NO] forKey:@"is_hidden"];
    
    //NSError *error;
    //[context save:&error];
    
    return newList;
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
    //NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[FriendListTableVc getSaveFilePath]];

    self.friendLists = [[NSMutableArray alloc] initWithCapacity:11];
    self.friendLists_hidden = [[NSMutableArray alloc] initWithCapacity:5];
    
    //Get Context
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
        
    
    //Get Entity
    NSEntityDescription *entityDesc = [NSEntityDescription    
                                       entityForName:@"List" inManagedObjectContext:context];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error;
    NSArray *matching_objects = [context executeFetchRequest:request error:&error]; ;
    for (NSManagedObject *obj in matching_objects)
    {
        NSNumber *isHidden = [obj valueForKey:@"is_hidden"];
        
        if ([isHidden boolValue])
            [self.friendLists_hidden addObject:obj];
        else
            [self.friendLists addObject:obj];
        NSLog(@"Found object: %@", [obj valueForKey:@"name"]);
    }

    NSLog(@"loaded data.  lists: %i, hidden: %i", self.friendLists.count, self.friendLists_hidden.count);
}

+(void) showHiddenLists
{
    //Get Context
    PspctAppDelegate *delegate = (PspctAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [delegate managedObjectContext];
    
    //Get Entity
    NSEntityDescription *entityDesc = [NSEntityDescription    
                                       entityForName:@"List" inManagedObjectContext:context];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *matching_objects = [context executeFetchRequest:request error:&error]; ;
    
    NSNumber *isHidden = [NSNumber numberWithBool:NO];
    for (NSManagedObject *obj in matching_objects)
    {
        [obj setValue:isHidden forKey:@"is_hidden"];
    }
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
    NSLog(@"getting cell");
    static NSString *CellIdentifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILongPressGestureRecognizer *recognizer  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editOrder:)];
    [cell addGestureRecognizer:recognizer];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSManagedObject *list = [self.friendLists objectAtIndex:indexPath.row];
    cell.textLabel.text = [list valueForKey:@"name"];
    NSLog(@"returning cell");
    
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
        //[self saveData];
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
        NSManagedObject *obj = [self.friendLists objectAtIndex:indexPath.row];
        [obj setValue:[NSNumber numberWithBool:YES] forKey:@"is_hidden"];
        [self.friendLists_hidden addObject:obj];
        [self.friendLists removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self updateRowOrder];
        
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
    
    [self updateRowOrder];
    
    NSLog(@"cell was moved");
}

-(void)updateRowOrder
{
    for (int i=0; i<self.friendLists.count; i++) {
        NSManagedObject *obj = [self.friendLists objectAtIndex:i];
        [obj setValue:[NSNumber numberWithInt:i] forKey:@"order"];
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
    
    NSManagedObject *list = [self.friendLists objectAtIndex:indexPath.row];
    [self setEditing:NO];
    
    FriendTableVc *friendTable = [[FriendTableVc alloc] initWithListId:[list valueForKey:@"id"] andListName:[list valueForKey:@"name"] andListType:[list valueForKey:@"list_type"]];
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
