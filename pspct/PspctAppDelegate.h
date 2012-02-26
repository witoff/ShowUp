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

@interface PspctAppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate>
{
    Facebook *facebook;
    MixpanelAPI *mixpanel;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) MixpanelAPI *mixpanel;

@end
