//
//  OptionsVc.m
//  pspct
//
//  Created by Robert Witoff on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsVc.h"
#import "PspctAppDelegate.h"
#import "Constants.h"
#import "GroupTableVc.h"

@implementation OptionsVc

-(id)initWithCoder:(NSCoder *)aDecoder
{
    //self = [super initWithStyle:UITableViewStyleGrouped];
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)awakeFromNib
{
    UITableView *tbv = [[UITableView alloc] initWithFrame:CGRectMake(0,80,320,480) style:UITableViewStyleGrouped];
    self.tableView = tbv;

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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    switch (indexPath.section) {
        case 0:
            //Show hidden lists
            cell.textLabel.text = @"Show Hidden Lists";
            break;
        case 11:
            //Show hidden friends
            cell.textLabel.text = @"Show Hidden Friends";      
            break;
        case 1:
            //Logout of facebook
            cell.textLabel.text = @"Logout of Facebook";
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected");
    
    NSString* strSuccess = nil;
    switch (indexPath.section) {
        case 0:
            //Show hidden lists
            [self showHiddenLists];
            strSuccess = @"Hidden Lists Re-added";
            break;
        case 11:
            //Show hidden friends
            [self showHiddenFriends];
            strSuccess = @"Hidden Friends Re-added";
            break;
        case 1:
            //Logout of facebook
            [self logoutOfFacebook];
            strSuccess = @"Logged out of Facebook";
            break;
        default:
            break;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:strSuccess delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showHiddenLists
{
    NSLog(@"hidden lists");
    [GroupTableVc showHiddenLists];

}

-(void)showHiddenFriends
{
    NSLog(@"hidden friends");
    //TODO: implement correctly
}

-(void)logoutOfFacebook
{
    NSLog(@"logout");
    PspctAppDelegate *appDelegate = (PspctAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.facebook logout];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];

    //DELETE ALL FILES
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:FRIEND_LIST_FILENAME];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSError *error;
    if ([fileMgr removeItemAtPath:filePath error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    // Show contents of Documents directory
    NSLog(@"Documents directory: %@",
          [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    */
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_FB_LOGOUT object:self];
}


@end
