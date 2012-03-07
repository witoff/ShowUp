//
//  PspctPredefinedMessageTableVc.m
//  pspct
//
//  Created by Robert Witoff on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TemplateTableVc.h"
#import "FriendTableVc.h"
#import "Constants.h"
#import "MixpanelAPI.h"

@interface TemplateTableVc (hidden)

+(NSString*)getSaveFilePath;

@end

@implementation TemplateTableVc

@synthesize messages;


-(id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
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
    
    self.navigationItem.title = @"Templates";
    [self loadTemplates];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        if (self.messages)
            return self.messages.count;
        return 0;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section==0)
    {
        UILongPressGestureRecognizer *recognizer  = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editOrder:)];
        [cell addGestureRecognizer:recognizer];
        cell.textLabel.text = [self.messages objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = @"Add Template";
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0)
        return nil;
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        //Send through parent 
        int controller_count = self.navigationController.viewControllers.count;
        FriendTableVc *friendVc = (FriendTableVc *)[self.navigationController.viewControllers objectAtIndex:controller_count-2];
        
        
        NSString *message = [self.messages objectAtIndex:indexPath.row];
        
        if ([message isEqualToString:@"<empty>"])
            message = @"";
        [friendVc sendSmsWithMessage:message];

    }
    else
    {
        //TODO: accept text here
        [self addTemplate:nil];
    }
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
        //done editing
        self.navigationItem.rightBarButtonItem = nil;
        [self saveData];
    }
    [super setEditing:editing animated:animated];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section==0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[MixpanelAPI sharedAPI] track:@"deleted template" properties:[NSDictionary dictionaryWithObject:[self.messages objectAtIndex:indexPath.row] forKey:@"text"]];
        
        [self.messages removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *obj = [self.messages objectAtIndex:fromIndexPath.row];
    [self.messages removeObjectAtIndex:fromIndexPath.row];
    [self.messages insertObject:obj atIndex:toIndexPath.row];
    
    NSLog(@"cell was moved");
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section==0);
}


#pragma mark - template editing

+(NSString*)getSaveFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:FILENAME_TEMPLATE];
    return filePath;
}

-(void)saveData
{
    NSLog(@"template table :: saving data");
    NSString *path = [TemplateTableVc getSaveFilePath];    
    [self.messages writeToFile:path atomically:YES];
}

-(void)loadTemplates
{
    NSString *path = [TemplateTableVc getSaveFilePath];    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if (![fileMgr fileExistsAtPath:path])
    {
        //load & save defaults if file doesn't exist
        self.messages = [[NSMutableArray alloc] initWithObjects:
                         @"<empty>",
                         @"Be right there", 
                         @"On my way!",
                         @"Want to grab lunch?",
                         @"Want to grab coffee?",
                         @"I'll be 10 mins late",
                         @"I'll be there ASAP",
                         @"Want to go for a run today?",
                         @"Want to catch a movie tonight?",
                         @"That's what she said?",
                         @"Checkout pspct.com!",
                         nil];
        [self.messages writeToFile:path atomically:YES];
        [self.tableView reloadData];
    }
    else
    {
        self.messages = [NSMutableArray arrayWithContentsOfFile:path];
    }
    
}

-(IBAction)addTemplate:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add a Template" message:@"Enter the text for a new Template message" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: @"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        NSString *text = [alertView textFieldAtIndex:0].text;
        [self.messages addObject:text];
        [self saveData];
        [self.tableView reloadData];
        
        [[MixpanelAPI sharedAPI] track:@"Added template" properties:[NSDictionary dictionaryWithObject:text forKey:@"text"]];
    }
}


@end
