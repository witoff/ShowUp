//
//  EventVc.m
//  pspct
//
//  Created by Robert Witoff on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventsVc.h"
#import "Facebook.h"
#import "PspctAppDelegate.h"
#import "ContactProviderAb.h"
#import <MessageUI/MessageUI.h>
#import "AbContact.h"
#import "EventAccessor.h"
#import <EventKit/EventKit.h>
#import "EventAttendeesVc.h"
#import "JSON.h"
#import "EventTableCell.h"

@interface EventsVc (hidden)

-(void)debugLogAllEvents;

@end

@implementation EventsVc

@synthesize birthdays, events;


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self =  [super initWithCoder:aDecoder];
    if (self)
    {
        //BUG: The vc may still default to the originally assigned tableview if a low memory warning is received.
        self.tableView = [[UITableView alloc] initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];
        
        didScroll = NO;
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
    NSLog(@"viewdidload: %@", self);
    if (self.navigationController.viewControllers.count==1)
    {
        NSLog(@"navcontroller: %@, %i", self.navigationController, self.navigationController.viewControllers.count);
        
        UIView *backgroundView = [[UIView alloc] initWithFrame: self.tableView.frame];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgClouds.png"]];
        [self.navigationController.view insertSubview:backgroundView atIndex:0];
        
        self.view.backgroundColor = [UIColor clearColor];    
        //[self.tableView.window makeKeyAndVisible];
    }
    
    //Setup Table
    EventAccessor *ea = [[EventAccessor alloc] init];
    self.events = [[NSMutableArray alloc] initWithCapacity:9];
    
    for (int i=-1; i<8; i++) {
        [self.events insertObject:[ea getEventsFromOffset:i to:i+1] atIndex:i+1];       
    }
    
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)debugLogAllEvents
{
    EventAccessor *ea = [[EventAccessor alloc] init];
    NSArray* ev = [ea getEventsFromOffset:-1000 to:7];
    
    NSMutableArray *jevents = [[NSMutableArray alloc] init];
    
    for (EKEvent *e in ev) {
        NSMutableArray* attendees = [[NSMutableArray alloc] initWithCapacity:e.attendees.count];
        for (EKParticipant *p in e.attendees)
            [attendees addObject:p.name];
        NSString* title = e.title ? e.title : @"";
        NSString* organizer = e.organizer.name ? e.organizer.name : @"";
        
        [jevents addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:title, @"title", organizer, @"organizer", attendees, @"attendees", nil]];
    }
    
    NSLog(@"%@", [jevents JSONRepresentation]);
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
    //Scroll to today on the first view
    if (!didScroll)
    {
        NSLog(@"%@ did scroll: %i", self, didScroll);
        didScroll=YES;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];    
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }
    
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Create the predicate's start and end dates.
    CFGregorianDate gregorianStartDate;
    CFGregorianUnits startUnits = {0, 0, section-1, 0, 0, 0};
    CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
    
    gregorianStartDate = CFAbsoluteTimeGetGregorianDate(
                                                        CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, startUnits),
                                                        timeZone);
    gregorianStartDate.hour = 0;
    gregorianStartDate.minute = 0;
    gregorianStartDate.second = 0;
    
    NSDate* startDate =
    [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianStartDate, timeZone)];
    
    CFRelease(timeZone);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE, M/d";
    NSString* dateString = [formatter stringFromDate:startDate];
    
    switch (section) {
        case 0:
            return [NSString stringWithFormat: @"Yesterday - %@", dateString];
        case 1:
            return [NSString stringWithFormat: @"Today - %@", dateString];
        case 2:
            return [NSString stringWithFormat: @"Tomorrow - %@", dateString];
        default:
            return dateString;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.events.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.events)
        return [[self.events objectAtIndex:section] count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    EventTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EventTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    EKEvent *event = [[self.events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = event.title;
    
    if ([event.startDate compare:[NSDate date]] == NSOrderedAscending)
    {
        
        cell.backgroundColor = [UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1];
        cell.textLabel.textColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1];
    }
    else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
    }
                        
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //formatter.dateFormat = @"HH:mm";
    formatter.dateFormat = @"ha";
    NSString *dateString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate: event.startDate], [formatter stringFromDate:event.endDate]];
    
    cell.detailTextLabel.text = [dateString lowercaseString];
    cell.lblAttendees.text = [NSString stringWithFormat:@"Attendees: %i", event.attendees.count];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.;
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
    EKEvent *event = [[self.events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSLog(@"\nAttendees:");
    
    for (EKParticipant *p in event.attendees) {
        NSLog(@"name: %@", p.name);
    }
    
    EventAttendeesVc* eavc = [[EventAttendeesVc alloc] initWithEvent:[[self.events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    
    [self.navigationController pushViewController:eavc animated:YES];
    
    
    //[self sendSms: [[self.birthdays objectAtIndex:indexPath.row] valueForKey:@"name"] ];
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
}


@end

