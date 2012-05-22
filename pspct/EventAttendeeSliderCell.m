//
//  EventAttendeeSliderCell.m
//  On Time
//
//  Created by Robert Witoff on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventAttendeeSliderCell.h"

@implementation EventAttendeeSliderCell

@synthesize _slider, _durationText, message;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    lastValue = -1;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self._slider = [[UISlider alloc]initWithFrame:CGRectMake(20, 2, 200, 40)];
        
        self._slider.maximumValue=1;
        self._slider.minimumValue = 0;
        self._slider.minimumTrackTintColor = [UIColor redColor];
        
        self._slider.continuous = YES;
        [self._slider addTarget:self
                        action:@selector(sliderChanged:) 
              forControlEvents:UIControlEventValueChanged];
        [self addSubview:_slider];
        
        self._durationText = [[UILabel alloc] initWithFrame:CGRectMake(240, 2, 80, 40)];
        self._durationText.backgroundColor = [UIColor clearColor];
        [self addSubview:self._durationText];

        //initialize textt
        [self sliderChanged:nil];
    }
    
    return self;
}

-(IBAction)sliderChanged:(id)sender
{
    
    NSString *lblText;
    int value = floor(self._slider.value*4);
    if (value==lastValue)
        return;
    lastValue = value;
    switch (value) {
        case 0:
            lblText = @"5 Min";
            self.message = @"Be there in 5 Mins!";
            break;
        case 1:
            lblText = @"10 Min";            
            self.message = @"Be there in 10 Mins!";
            break;
        case 2:
            lblText = @"20 Min";
            self.message = @"Be there in 20 Mins!";
            break;
        case 3:
            lblText = @"30 Min";
            self.message = @"Be there in 30 Mins!";
            break;
        case 4:
            lblText = @"Cancel";
            self.message = @"Sorry but I can't make our meeting today.  Can we reschedule?";
            break;
        default:
            break;
    }
    logDebug(@"updating text to: %@", lblText);
    self._durationText.text = lblText;
    [self._durationText setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
