//
//  PspctFriendTableVc.m
//  pspct
//
//  Created by Robert Witoff on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PspctFriendTableVc.h"
#import "PspctAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "ScanAddressBook.h"
#import "SimpleRequester.h"

@implementation PspctFriendTableVc

@synthesize listId, friends, friends_hidden, listName, listType, selected;

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
    self.friends = [result objectForKey:@"data"];
    self.friends_hidden = [[NSMutableArray alloc] initWithCapacity:11];
    self.selected = [[NSMutableArray alloc] initWithArray:self.friends];    
    for (int i=0; i<self.selected.count; i++) {
        [self.selected replaceObjectAtIndex:i withObject:@"yes"];
    }
    
    for (NSString* key in [result keyEnumerator]) {
        NSLog(@"key: %@", key);
    }
    
    NSLog(@"facebook response, %i friends", self.friends.count);
    
    for (NSDictionary *list in self.friends) {
        NSLog(@"%@", [list objectForKey:@"name"]);
    }

    NSLog(@"type: %@", self.listType);
    if ([self.listType isEqualToString:@"family"])
    {
        NSLog(@"we have a family");
        [self.friends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Mom",@"name", nil]];
        [self.selected addObject:@"yes"];
        [self.friends addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Dad",@"name", nil]];
        [self.selected addObject:@"yes"];
    }
    
    
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
    PspctAppDelegate *appDelegate = (PspctAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString* endpoint = [NSString stringWithFormat:@"%@/members", self.listId, nil];
    NSLog(@"--asking for friends from: %@", endpoint);

    [appDelegate.facebook requestWithGraphPath:endpoint andDelegate:self];

    self.navigationItem.title = self.listName;
    
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
    if ([[self.selected objectAtIndex:indexPath.row] isEqualToString:@"yes"])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selection found");
    
    if ([[self.selected objectAtIndex:indexPath.row] isEqualToString:@"yes"])
        [self.selected replaceObjectAtIndex:indexPath.row withObject:@"no"];
    else
        [self.selected replaceObjectAtIndex:indexPath.row withObject:@"yes"];
    
    [self.tableView reloadData];
    return;
    
    if (![MFMessageComposeViewController canSendText])
    { 
        NSLog(@"Can't send text");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot send a message" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
}

- (IBAction)sendMessage:(id)sender
{
    
    MFMessageComposeViewController *messageVc = [[MFMessageComposeViewController alloc] init];
    
    messageVc.messageComposeDelegate = self;
    
    NSMutableArray *recipients = [[NSMutableArray alloc] initWithCapacity:5];
    //get last name
    ScanAddressBook *addressBook = [[ScanAddressBook alloc] init];
    for (int i=0; i<self.selected.count; i++) {
        
        if ([[self.selected objectAtIndex:i] isEqualToString:@"no"])
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
        [self.friends removeObjectAtIndex:indexPath.row];
        [self.selected removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
