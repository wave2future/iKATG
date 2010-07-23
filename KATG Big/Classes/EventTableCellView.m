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

#import "EventTableCellView.h"
#import <QuartzCore/QuartzCore.h>
#import "AccView.h"

@interface EventTableCellView ()
- (void)setup;
@end

@implementation EventTableCellView
@synthesize eventTypeImageView;
@synthesize eventTitleLabel;
@synthesize eventDayLabel;
@synthesize eventDateLabel;
@synthesize eventTimeLabel;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:(NSCoder *)aDecoder]) 
	{
		[self setup];
    }
    return self;
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
	UIView			*	view		=	[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
	view.backgroundColor			=	[UIColor clearColor];
	CAGradientLayer	*	gradient	=	[CAGradientLayer layer];
	CGRect				gradFrame	=	view.bounds;
//	gradFrame.origin.y				+=	2.0;
//	gradFrame.size.height			-=	3.0;
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
	self.backgroundView				=	view;
	[view release]; view			=	nil;
	
	view							=	[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
	view.backgroundColor			=	[UIColor colorWithRed:(CGFloat)(112.0/255.0) 
											 green:(CGFloat)(174.0/255.0) 
											  blue:(CGFloat)(36.0/255.0) 
											 alpha:1.0];
	self.selectedBackgroundView		=	view;
	[view release];
}
//- (void)drawRect:(CGRect)rect 
//{
//	[super drawRect:rect];
//	
//	// Setup context
//	CGContextRef	context	=	UIGraphicsGetCurrentContext();
//	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(CGFloat)(156.0/255.0) 
//															   green:(CGFloat)(199.0/255.0) 
//																blue:(CGFloat)(151.0/255.0) 
//															   alpha:1.0] CGColor]);
//	//CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
//	CGContextSetLineWidth(context, 2.0);
//	
//	// Map top line path
//	CGContextMoveToPoint(context, 0.0, 0.0);
//	CGContextAddLineToPoint(context, rect.size.width, 0.0);
//	
//	// Draw it
//	CGContextStrokePath(context);
//	
//	// Change stroke color
//	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(CGFloat)(43.0/255.0) 
//															   green:(CGFloat)(107.0/255.0) 
//																blue:(CGFloat)(35.0/255.0) 
//															   alpha:1.0] CGColor]);
//	//CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
//	
//	// Change stroke size
//	CGContextSetLineWidth(context, 1.0);
//	
//	// Map  bottom line path
//	CGContextMoveToPoint(context, 0.0, rect.size.height);
//	CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
//	
//	// Draw it
//	CGContextStrokePath(context);
//}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	[super setSelected:selected animated:animated];
	if (selected)
	{
		UIColor	*	gray	=	[UIColor colorWithRed:(CGFloat)(174.0/255.0) 
										 green:(CGFloat)(174.0/255.0) 
										  blue:(CGFloat)(174.0/255.0) 
										 alpha:1.0];
//		[self.eventTitleLabel setTextColor:gray];
//		[self.eventTitleLabel setShadowColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5]];
//		[self.eventDayLabel setTextColor:gray];
//		[self.eventDateLabel setTextColor:gray];
//		[self.eventTimeLabel setTextColor:gray];
		[(AccView *)self.accessoryView setArrowColor:gray];
		[(AccView *)self.accessoryView setNeedsDisplay];
	}
	else 
	{
//		[self.eventTitleLabel setTextColor:[UIColor whiteColor]];
//		[self.eventTitleLabel setShadowColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5]];
//		[self.eventDayLabel setTextColor:[UIColor whiteColor]];
//		[self.eventDateLabel setTextColor:[UIColor whiteColor]];
//		[self.eventTimeLabel setTextColor:[UIColor whiteColor]];
		[(AccView *)self.accessoryView setArrowColor:[UIColor whiteColor]];
		[(AccView *)self.accessoryView setNeedsDisplay];
	}
}
- (void)dealloc 
{
	[eventTypeImageView release];
	[eventTitleLabel release];
	[eventDayLabel release];
	[eventDateLabel release];
	[eventTimeLabel release];
    [super dealloc];
}

@end
