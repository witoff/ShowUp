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

@interface PspctAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate>
{
    Facebook *facebook;
    MixpanelAPI *mixpanel;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) MixpanelAPI *mixpanel;

-(void)fbAuthorize;

@end
