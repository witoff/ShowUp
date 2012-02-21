//
//  OptionsVc.m
//  pspct
//
//  Created by Robert Witoff on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsVc.h"
#import "PspctAppDelegate.h"

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
    return 3;
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
    
    
    UITapGestureRecognizer *recognizer;
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Show Hidden Lists";
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHiddenLists:)];
            [cell addGestureRecognizer:recognizer];
            break;
        case 1:
            cell.textLabel.text = @"Show Hidden Friends";
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHiddenFriends:)];
            [cell addGestureRecognizer:recognizer];
            break;
        case 2:
            cell.textLabel.text = @"Logout of Facebook";
            recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutOfFacebook:)];
            [cell addGestureRecognizer:recognizer];
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
}

-(IBAction)showHiddenLists:(id)sender
{
    NSLog(@"hidden lists");
    //TODO: implement correctly

}
-(IBAction)showHiddenFriends:(id)sender
{
    NSLog(@"hidden friends");
    //TODO: implement
    
}
-(IBAction)logoutOfFacebook:(id)sender
{
    NSLog(@"logout");
    PspctAppDelegate *appDelegate = (PspctAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.facebook logout];
}


@end
