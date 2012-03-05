//
//  PspctAppDelegate.m
//  pspct
//
//  Created by Robert Witoff on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PspctAppDelegate.h"
#import "AbScanner.h"
#import "MixpanelAPI.h"
#import "Constants.h"

@interface PspctAppDelegate (hidden)

-(void)showCorrectRootView;

@end

@implementation PspctAppDelegate

@synthesize window = _window, facebook, mixpanel, viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"application :: didFinishLaunchingWithOptions");
    mixpanel = [MixpanelAPI sharedAPIWithToken:@"30cb438635ae2386bbde7c4ef81fd191"];
    facebook = [[Facebook alloc] initWithAppId:@"246082168796906" andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self showCorrectRootView];
    
    return YES;
}

-(void)showCorrectRootView
{
    //Launch Intro or storyboard
    
    if (self.viewController != nil)
    {
        if([facebook isSessionValid] && [self.window.rootViewController class ] != [IntroVc class])
            return;
        if(![facebook isSessionValid] && [self.window.rootViewController class ] == [IntroVc class])
            return;
    }
    
    if (![facebook isSessionValid]) {
        self.viewController = [[IntroVc alloc] initWithNibName:@"IntroVc" bundle:nil];
    }
    else
    {
        mixpanel.nameTag = facebook.
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        self.viewController = [storyboard instantiateInitialViewController];
    }
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
}

/* If needed authorize the Fb User */
-(void)fbAuthorize
{
    if (![facebook isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"read_friendlists", @"offline_access", @"user_events", @"manage_friendlists", @"friends_birthday", @"user_relationships", nil];
        [facebook authorize:permissions];
    }
    else
    {
        [self showCorrectRootView];
    }
}

#pragma mark - FACEBOOK SUPPORT
// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"handleOpenURL");
    return [facebook handleOpenURL:url]; 
}



// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}
- (void)fbDidLogin {
    NSLog(@"fbDidLogin");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_FB_LOGIN object:self];
    
    [self showCorrectRootView];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}
-(void)fbDidLogout{}
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
    
    [self showCorrectRootView];
    
    //invalidate contact list... may have changed while you were outside of the app
    [AbScanner invalidateContactList];
    
    [facebook extendAccessTokenIfNeeded];
    
    [mixpanel track:@"opened application"]; 
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
