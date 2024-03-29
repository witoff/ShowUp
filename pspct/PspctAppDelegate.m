//
//  PspctAppDelegate.m
//  pspct
//
//  Created by Robert Witoff on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PspctAppDelegate.h"
#import "PspctTabBarController.h"
#import "MixpanelAPI.h"
#import "Constants.h"
#import <CoreData/CoreData.h>
#import "ContactProviderAb.h"
#import <MessageUI/MessageUI.h>

@interface PspctAppDelegate (hidden)

-(void)showCorrectRootView;
-(IBAction)preloadMFMessage:(id)sender;

@end

@implementation PspctAppDelegate

@synthesize window = _window, viewController = _viewController;
@synthesize facebook, mixpanel, store;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    logDebug(@"debud bedarstarst ");
    //FORMAT STATUS BAR
    [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    
    //SETUP FRAMEWORKS
    self.mixpanel = [MixpanelAPI sharedAPIWithToken:@"12a3027a7865c7f01d1531534e05cba9"];    
    self.store = [[EKEventStore alloc] init];
    //facebook = [[Facebook alloc] initWithAppId:@"246082168796906" andDelegate:self];
    
    //PRELOAD MFMESSAGE
    [self performSelectorInBackground:@selector(preloadMFMessage:) withObject:nil];
    
    //PERSISTANT DATA
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    /*
     if ([defaults objectForKey:@"FBAccessTokenKey"] 
     && [defaults objectForKey:@"FBExpirationDateKey"]) {
     facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
     facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
     }
     
     if ([defaults objectForKey:@"FBName"])
     {
     mixpanel.nameTag = [defaults objectForKey:@"FBName"];
     NSLog(@"setting mixpanel name to: %@", [defaults objectForKey:@"FBName"]);
     }
     */
    [self.mixpanel track:@"appDidFinishLaunching"];
    
    //SETUP WINDOW
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self showCorrectRootView];
    
    return YES;
}

/** The first load of this class can take up to 9 seconds.  Better to do it on app load then right before sending a message **/
-(IBAction)preloadMFMessage:(id)sender
{
    if ([MFMessageComposeViewController canSendText])
    {
        logDebug(@"starting MFMessage init");
        MFMessageComposeViewController *messageVc = [[MFMessageComposeViewController alloc] init];
        logDebug(@"finished MFMessage init");
        
        //messageVc.messageComposeDelegate = self;
        messageVc.body = @"";
    }
}

-(void)showCorrectRootView
{
    //Launch Intro or storyboard
    
    //Do nothing if correct vc is already displayed
    if (self.window.rootViewController == nil)
    {
        //First launch of the application
        
        logInfo(@"Not displaying the home tab bar controller, must be our first launch.  Rebuilding storyboard.");
        //Navigation controller is only visible after on the main page
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        self.viewController = [storyboard instantiateInitialViewController];
        
        //Set Background
        UIView *backgroundView = [[UIView alloc] initWithFrame: self.window.frame];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgClouds.png"]];
        [self.viewController.view insertSubview:backgroundView atIndex:0];
        
        self.window.rootViewController = self.viewController;
        [self.window makeKeyAndVisible];
    }
    else if (self.window.rootViewController.class != [PspctTabBarController class])
    {
        //App already launched but not viewing the tab bar controller
    }
    
}

#pragma mark - FACEBOOK SUPPORT

/* If needed authorize the Fb User */
-(void)fbAuthorize
{
    if (![facebook isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"read_friendlists", @"offline_access", @"user_events", @"manage_friendlists", @"friends_birthday", @"user_relationships", @"user_groups", nil];
        [facebook authorize:permissions];
    }
    else
    {
        [self showCorrectRootView];
    }
}

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    logDebug(@"handleOpenURL");
    return [facebook handleOpenURL:url]; 
}



// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}
- (void)fbDidLogin {
    logInfo(@"fbDidLogin");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_FB_LOGIN object:self];
    
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    
    [self showCorrectRootView];
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    logInfo(@"failed fb request: %@", error.description);
}
-(void)request:(FBRequest *)request didLoad:(id)result{
    
    NSDictionary *response = (NSDictionary*)result;
    
    NSString* name = [response objectForKey:@"name"];
    if (name)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:name forKey:@"FBName"];
        [self.mixpanel setNameTag:name];
        logInfo(@"setting mixpanel name to: %@", name);
        [defaults synchronize];
    }
    
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    logInfo(@"token extended");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}
-(void)fbDidLogout{
    logInfo(@"fbDidLogout");
    
    
}
-(void)fbDidNotLogin:(BOOL)cancelled{}
-(void)fbSessionInvalidated{}

#pragma mark - iOS Methods
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self saveContext];
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self.mixpanel track:@"appDidBecomeActive"];
    
    [self showCorrectRootView];
    
    //invalidate contact list... may have changed while you were outside of the app
    [ContactProviderAb invalidateContactList];
    
    [facebook extendAccessTokenIfNeeded];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



- (void)saveContext
{
    /*
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            
            //Replace this implementation with code to handle the error appropriately.
             
             //abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping
            //application, although it may be useful during development. 

            logDebug(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    */
}

#pragma mark - Core Data stack

//Code removed... see GroupMessenger

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
