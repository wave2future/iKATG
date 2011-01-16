//
//  EventTableCellView.m
//  KATG.com
//
//  Copyright 2009 Doug Russell
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  

#import "EventTableViewCell.h"
#import "AccView.h"

@interface EventTableViewCell ()
- (void)setup;
@end

@implementation EventTableViewCell
@synthesize eventTypeImageView;
@synthesize eventTitleLabel;
@synthesize eventDayLabel;
@synthesize eventDateLabel;
@synthesize eventTimeLabel;
@synthesize	accessoryViewColor;
@synthesize	selectedAccessoryViewColor;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:(NSCoder *)aDecoder]) 
	{
		
    }
    return self;
}
- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setup];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) 
	{
		[self setup];
	}
	return self;
}
- (void)setup
{
	//	
	//	
	//	
	self.autoresizingMask			=	(UIViewAutoresizingFlexibleHeight);
	//	
	//	
	//	
	UIView			*	view		=	[[UIView alloc] initWithFrame:self.frame];
	view.autoresizingMask			=	UIViewAutoresizingFlexibleWidth;
	view.backgroundColor			=	[UIColor colorWithRed:(CGFloat)(112.0/255.0) 
											 green:(CGFloat)(174.0/255.0) 
											  blue:(CGFloat)(36.0/255.0) 
											 alpha:1.0];
	if (HasMultitasking())
	{
		gradient						=	[[CAGradientLayer layer] retain];
		CGRect				gradFrame	=	view.bounds;
		gradient.frame					=	gradFrame;
		gradient.colors					=	[NSArray arrayWithObjects:
											 (id)[[UIColor colorWithRed:(CGFloat)(112.0/255.0) 
																  green:(CGFloat)(174.0/255.0) 
																   blue:(CGFloat)(36.0/255.0) 
																  alpha:1.0] CGColor], 
											 (id)[[UIColor colorWithRed:(CGFloat)(57.0/255.0) 
																  green:(CGFloat)(143.0/255.0) 
																   blue:(CGFloat)(47.0/255.0) 
																  alpha:1.0] CGColor], nil];
		[view.layer insertSublayer:gradient atIndex:0];
	}
	self.backgroundView				=	view;
	[view release]; view			=	nil;
	//	
	//	
	//	
	view							=	[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
	view.backgroundColor			=	[UIColor colorWithRed:(CGFloat)(112.0/255.0) 
											 green:(CGFloat)(174.0/255.0) 
											  blue:(CGFloat)(36.0/255.0) 
											 alpha:1.0];
	view.autoresizingMask			=	UIViewAutoresizingFlexibleWidth;
	self.selectedBackgroundView		=	view;
	[view release];
	//	
	//	
	//	
	self.accessoryViewColor			=	[UIColor whiteColor];
	self.selectedAccessoryViewColor	=	[UIColor colorWithRed:(CGFloat)(174.0/255.0) 
													  green:(CGFloat)(174.0/255.0) 
													   blue:(CGFloat)(174.0/255.0) 
													  alpha:1.0];
}
- (void)drawRect:(CGRect)rect 
{
	[super drawRect:rect];
	gradient.frame	=	self.backgroundView.bounds;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	[super setSelected:selected animated:animated];
	if (selected)
	{
//		[self.eventTitleLabel setTextColor:self.selectedAccessoryViewColor];
//		[self.eventTitleLabel setShadowColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5]];
//		[self.eventDayLabel setTextColor:self.selectedAccessoryViewColor];
//		[self.eventDateLabel setTextColor:self.selectedAccessoryViewColor];
//		[self.eventTimeLabel setTextColor:self.selectedAccessoryViewColor];
		[(AccView *)self.accessoryView setArrowColor:self.selectedAccessoryViewColor];
		[(AccView *)self.accessoryView setNeedsDisplay];
	}
	else 
	{
//		[self.eventTitleLabel setTextColor:self.accessoryViewColor];
//		[self.eventTitleLabel setShadowColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5]];
//		[self.eventDayLabel setTextColor:self.accessoryViewColor];
//		[self.eventDateLabel setTextColor:self.accessoryViewColor];
//		[self.eventTimeLabel setTextColor:self.accessoryViewColor];
		[(AccView *)self.accessoryView setArrowColor:self.accessoryViewColor];
		[(AccView *)self.accessoryView setNeedsDisplay];
	}
}
- (void)dealloc 
{
	[accessoryViewColor release];
	[selectedAccessoryViewColor release];
	[gradient release];
	[eventTypeImageView release];
	[eventTitleLabel release];
	[eventDayLabel release];
	[eventDateLabel release];
	[eventTimeLabel release];
    [super dealloc];
}

@end
