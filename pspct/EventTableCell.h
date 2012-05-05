//
//  EventTableCell.h
//  perspect calendar
//
//  Created by Robert Witoff on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableCell : UITableViewCell
{
    @private
    UILabel *lblAttendees;
}

@property (nonatomic, retain) UILabel *lblAttendees;


@end
