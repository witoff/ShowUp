//
//  EventVc.m
//  pspct
//
//  Created by Robert Witoff on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventVc.h"
#import "Facebook.h"
#import "PspctAppDelegate.h"
#import "AbScanner.h"
#import <MessageUI/MessageUI.h>
#import "AbContact.h"

@implementation EventVc

@synthesize birthdays;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - facebook
-(void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"event response received, merging data");
    
    NSArray *all_friends = [result objectForKey:@"data"];
    NSMutableArray *bday_friends = [[NSMutableArray alloc] initWithCapacity:all_friends.count];
    
    //remove no b-days
    for (NSDictionary *friend in all_friends) {
        if ([friend objectForKey:@"birthday"])
        {
            NSString* bday = [friend objectForKey:@"birthday"];
            int month = [bday substringToIndex:2].integerValue;
            int day = [bday substringWithRange:NSMakeRange(3, 2)].integerValue;
            int doy = day + month*31;
            
            [friend setValue:[NSNumber numberWithInt:doy] forKey:@"doy"];
            [bday_friends addObject:friend];
        }
    }
    
    //sort
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"doy" ascending:YES];
    NSArray *sortedArr = [bday_friends sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    //find today's index
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    
    int doy = components.day + (31 * components.month);
    int scroll_index = 0;
    for (; scroll_index<sortedArr.count; scroll_index++) {
        if ([[[sortedArr objectAtIndex:scroll_index] objectForKey:@"doy"] integerValue] >= doy)
            break;
    }
    
    self.birthdays = sortedArr;
    [self.tableView reloadData];
    
    
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:scroll_index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}
-(void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"EventVc :: Error in FB Request: %@", error.description);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error in Facebook request" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    PspctAppDelegate *appDelegate = (PspctAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //TODO: paging??
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"id,name,birthday",@"fields", @"500", @"limit", nil];
    [appDelegate.facebook requestWithGraphPath:@"me/friends" andParams:params andDelegate:self];
    
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.birthdays)
        return self.birthdays.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *bday = [self.birthdays objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [bday objectForKey:@"name"], [bday objectForKey:@"birthday"]];
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
    [self sendSms: [[self.birthdays objectAtIndex:indexPath.row] valueForKey:@"name"] ];
}

-(NSArray*)getContactDetails:(NSString*)firstname andLast:(NSString*)lastname
{
    NSMutableArray *recipients = [[NSMutableArray alloc] initWithCapacity:5];
    //get last name
    AbScanner *addressBook = [[AbScanner alloc] init];
        
    //get number
    AbContact *contact = [addressBook simpleSearch];
    
    if (contact)
        [recipients addObject:[contact getBestNumber]];
    
    return recipients;
}

- (void)sendSms:(NSString*)fullname
{
    MFMessageComposeViewController *messageVc = [[MFMessageComposeViewController alloc] init];
    
    //messageVc.messageComposeDelegate = self;
    
    NSArray *components = [fullname componentsSeparatedByString:@" "];
    
    NSString *lastname = nil;
    if (components.count>1)
        lastname = [components objectAtIndex:components.count-1];
    NSString* firstname = [components objectAtIndex:0];
    
    messageVc.recipients = [self getContactDetails:firstname andLast:lastname];
    messageVc.body = [NSString stringWithFormat: @"Happy Birthday %@!", firstname];
    
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

@end
