//
//  EventAttendeeSliderCell.h
//  On Time
//
//  Created by Robert Witoff on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventAttendeeSliderCell : UITableViewCell
{
    
    NSString* message;
    @private
    UISlider *_slider;
    UILabel *_durationText;
    int lastValue;
}

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UILabel *durationText;

-(IBAction)sliderChanged:(id)sender;

@end
