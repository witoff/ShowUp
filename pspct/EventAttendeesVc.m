//
//  EventAttendeesVc.m
//  perspect calendar
//
//  Created by Robert Witoff on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventAttendeesVc.h"
#import "ContactProviderAb.h"
#import "AbContact.h"
#import <MessageUI/MessageUI.h>
#import "MixpanelAPI.h"
#import "FullNameParser.h" 
#import "ContactSearcher.h"
#import "ContactTextParser.h"

@interface EventAttendeesVc ()

- (void)sendSmsWithMessage:(NSString*)message andRecipients:(NSArray*)recipients;

@end

@implementation EventAttendeesVc

@synthesize event, attendees, attendeeContacts, imgMissing, _title_contacts;

-(id)initWithEvent:(EKEvent *)evt
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.event = evt;
    }
    return self;
}

-(AbContact*)findContact:(EKParticipant*)participant
{
    FullNameParser *parser = [[FullNameParser alloc] initWithName:participant.name];
    
    ContactSearcher *searcher = [[ContactSearcher alloc] initWithContactProvider:[ContactProvider defaultProvider] andFirstname:[parser getFirstname] andLastname:[parser getLastname]];
    
    AbContact *contact = [searcher getMatchingAbContact];
    
    if (!contact)
    {
        NSLog(@"No contact found!");
        return nil;
    }
    
    NSLog(@"found: %@ - %@", contact.firstname, contact.lastname);
    return contact;
}

-(void)parseContacts
{
    
    //Add all attendees
    for (EKParticipant *participant in self.event.attendees) {
        AbContact *contact = [self findContact:participant];
        if (contact)
        {
            [attendeeContacts setValue:contact forKey:participant.name];
            [self.attendees insertObject:participant atIndex:0];
        }
        else
            [self.attendees insertObject:participant atIndex:self.attendees.count];
    }
    
    //Add the organizer
    if (self.event.organizer)
    {
        AbContact *contact = [self findContact:self.event.organizer];
        if (contact)
            [attendeeContacts setValue:contact forKey:self.event.organizer.name];
        [self.attendees insertObject:self.event.organizer atIndex:0];
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
    
    //Find contacts in the title
    ContactTextParser *parser = [[ContactTextParser alloc] initWithText:self.event.title];
    
    self._title_contacts = [parser getContacts];
    NSLog(@"contacts found in title: %i", self._title_contacts.count);
    
    self.attendees = [[NSMutableArray alloc] initWithCapacity:self.event.attendees.count+1];
    self.attendeeContacts = [[NSMutableDictionary alloc] initWithCapacity:self.event.attendees.count+1];
    
    
    [self parseContacts];
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
    return self._title_contacts.count + self.attendees.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AttendeeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EKParticipant *participant = nil;
    AbContact *contact = nil;
    
    if (indexPath.row<self._title_contacts.count){
        contact = [self._title_contacts objectAtIndex:indexPath.row ];
    }
    else {
        int index = indexPath.row-self._title_contacts.count;
        NSLog(@"index: %i", index);
        participant = [self.attendees objectAtIndex:index];
        contact = [attendeeContacts objectForKey:participant.name];
    }

    if (contact)
    {
        if (contact.lastname)
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstname, contact.lastname];
        else
            cell.textLabel.text = contact.firstname;
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
    AbContact *contact = nil;
    if (indexPath.row<self._title_contacts.count)
    {
        contact = [self._title_contacts objectAtIndex:indexPath.row];
    }
    else
    {
        EKParticipant *participant = [self.attendees objectAtIndex:indexPath.row];
        contact = [attendeeContacts objectForKey:participant.name];
    }
    [self sendSmsWithMessage:@"On my way!" andRecipients:[[NSArray alloc] initWithObjects:[[contact.numbers objectAtIndex:0] valueForKey:@"number"], nil]];
}

@end
