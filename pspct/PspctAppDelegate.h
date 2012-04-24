//
//  PspctAppDelegate.h
//  pspct
//
//  Created by Robert Witoff on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "MixpanelAPI.h"
#import "IntroVc.h"
#import <EventKit/EventKit.h>

@interface PspctAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, FBRequestDelegate>
{
    Facebook *facebook;
    MixpanelAPI *mixpanel;
    EKEventStore *store;
    
}

//Views
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
//Libs
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) MixpanelAPI *mixpanel;
-(void)fbAuthorize;
//Core Data
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
//Events
@property (nonatomic, retain) EKEventStore *store;

@end
