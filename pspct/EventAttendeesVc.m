//
//  EventAttendeesVc.m
//  perspect calendar
//
//  Created by Robert Witoff on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventAttendeesVc.h"
#import "AbScanner.h"
#import "AbContact.h"
#import <MessageUI/MessageUI.h>
#import "MixpanelAPI.h"

@interface EventAttendeesVc ()

- (void)sendSmsWithMessage:(NSString*)message andRecipients:(NSArray*)recipients;

@end

@implementation EventAttendeesVc

@synthesize event, attendeeContacts, imgMissing;

-(id)initWithEvent:(EKEvent *)evt
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.event = evt;
    }
    return self;
}

-(void)parseContacts
{
    attendeeContacts = [[NSMutableDictionary alloc] initWithCapacity:self.event.attendees.count];
    
    NSError *error;
    for (EKParticipant *participant in self.event.attendees) {
        NSLog(@"\n New Name");
        
        NSString *firstname;
        NSString *lastname;
        
        
        NSMutableString *name = [[NSMutableString alloc] initWithString:participant.name];
        NSLog(@"name: %@", name);

        //Remove any organization referenced in the attendee name
        error = nil;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\(.*\\)" options:0 error:&error];
        
        [regex replaceMatchesInString:name options:0 range:NSMakeRange(0, name.length) withTemplate:@""];
        NSLog(@"name: %@", name);
        
        //Split into first and lastname
        NSArray* components = [name componentsSeparatedByString:@","];
        if (components.count!=2)
        {
            NSLog(@"components !=1, skipping");
            continue;
        }

        //Strip whitespace and assign
        firstname = [[components objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        lastname = [[components objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        //Strip a trailing middle initial
        error = nil;
        regex = [[NSRegularExpression alloc] initWithPattern:@"\\s.*" options:0 error:&error];
        firstname = [regex stringByReplacingMatchesInString:firstname options:0 range:NSMakeRange(0, firstname.length) withTemplate:@""];
        
        NSLog(@"firstname: %@", firstname);
        NSLog(@"lastname: %@", lastname);
        
        AbScanner *scanner = [[AbScanner alloc] initWithFirstname:firstname andLastname:lastname];
        AbContact *contact = [scanner getMatchingAbContact];
        
        if (!contact)
        {
            NSLog(@"No contact found!");
            continue;
        }
        
        [attendeeContacts setValue:contact forKey:participant.name];
        
        NSLog(@"found: %@ - %@", contact.firstname, contact.lastname);
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self parseContacts];
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.event && self.event.attendees)
    {
        return self.event.attendees.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AttendeeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    
    EKParticipant *participant =[self.event.attendees objectAtIndex:indexPath.row];
    AbContact *contact = [attendeeContacts objectForKey:participant.name];

    if (contact)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstname, contact.lastname];
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.textLabel.text = participant.name;
        if (!self.imgMissing)
            self.imgMissing = [UIImage imageNamed:@"184-warning"];
        
        cell.imageView.image = self.imgMissing;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)sendSmsWithMessage:(NSString*)message andRecipients:(NSArray*)recipients
{
    MFMessageComposeViewController *messageVc = [[MFMessageComposeViewController alloc] init];
    
    messageVc.messageComposeDelegate = self;
 
    messageVc.recipients = recipients;
    messageVc.body = message;
    
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

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryDisclosureIndicator)
        return indexPath;
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EKParticipant *participant = [self.event.attendees objectAtIndex:indexPath.row];
    AbContact *contact = [attendeeContacts objectForKey:participant.name];
    
    [self sendSmsWithMessage:@"On my way!" andRecipients:[[NSArray alloc] initWithObjects:[[contact.numbers objectAtIndex:0] valueForKey:@"number"], nil]];
}

@end
