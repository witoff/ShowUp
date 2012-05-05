//
//  EventTableCell.m
//  perspect calendar
//
//  Created by Robert Witoff on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventTableCell.h"

@implementation EventTableCell

@synthesize lblAttendees;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) { 
        lblAttendees = [[UILabel alloc] initWithFrame:CGRectMake(200, 37, 120, 10)];
        lblAttendees.font = [UIFont systemFontOfSize:14];
        lblAttendees.textColor = [UIColor grayColor];
        lblAttendees.backgroundColor = [UIColor clearColor];
        [self addSubview:lblAttendees];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
