//
//  ArchiveTableViewCell.m
//  KATG Big
//
//  Created by Doug Russell on 7/11/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import "ArchiveTableViewCell.h"
#import <Quartzcore/QuartzCore.h>
#import "AccView.h"

@interface ArchiveTableViewCell ()
- (void)setup;
@end

@implementation ArchiveTableViewCell
@synthesize showTypeImageView = _showTypeImageView;
@synthesize showNumberLabel = _showNumberLabel;
@synthesize showTitleLabel = _showTitleLabel;
@synthesize showGuestsLabel = _showGuestsLabel;
@synthesize showNotesImageView = _showNotesImageView;
@synthesize showPicsImageView = _showPicsImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) 
	{
		[self setup];
	}
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:(NSCoder *)aDecoder]) 
	{
		[self setup];
    }
    return self;
}
- (void)setup
{
	UIView			*	view		=	[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
	view.backgroundColor			=	[UIColor colorWithRed:(CGFloat)(112.0/255.0) 
											 green:(CGFloat)(174.0/255.0) 
											  blue:(CGFloat)(36.0/255.0) 
											 alpha:1.0];
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
//		if ([self.showTypeImageView.image isEqual:[UIImage imageNamed:@"TVShow"]])
//			self.showTypeImageView.image	=	[UIImage imageNamed:@"TVShowSelected"];
//		else if ([self.showTypeImageView.image isEqual:[UIImage imageNamed:@"AudioShow"]])
//			self.showTypeImageView.image	=	[UIImage imageNamed:@"AudioShowSelected"];
//		if (self.showNotesImageView.image != nil)
//			self.showNotesImageView.image	=	[UIImage imageNamed:@"HasNotesSelected"];
//		if (self.showPicsImageView.image != nil)
//			self.showPicsImageView.image	=	[UIImage imageNamed:@"HasPicsSelected"];
//		[self.showTitleLabel setTextColor:gray];
//		[self.showTitleLabel setShadowColor:[UIColor clearColor]];
//		[self.showGuestsLabel setTextColor:gray];
//		[self.showGuestsLabel setShadowColor:[UIColor clearColor]];
		[(AccView *)self.accessoryView setArrowColor:gray];
		[(AccView *)self.accessoryView setNeedsDisplay];
	}
	else 
	{
//		if ([self.showTypeImageView.image isEqual:[UIImage imageNamed:@"TVShowSelected"]])
//			self.showTypeImageView.image	=	[UIImage imageNamed:@"TVShow"];
//		else if ([self.showTypeImageView.image isEqual:[UIImage imageNamed:@"AudioShowSelected"]])
//			self.showTypeImageView.image	=	[UIImage imageNamed:@"AudioShow"];
//		if (self.showNotesImageView.image != nil)
//			self.showNotesImageView.image	=	[UIImage imageNamed:@"HasNotes"];
//		if (self.showPicsImageView.image != nil)
//			self.showPicsImageView.image	=	[UIImage imageNamed:@"HasPics"];
//		[self.showTitleLabel setTextColor:[UIColor whiteColor]];
//		[self.showTitleLabel setShadowColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.5]];
//		[self.showGuestsLabel setTextColor:[UIColor whiteColor]];
//		[self.showGuestsLabel setShadowColor:[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.5]];
		[(AccView *)self.accessoryView setArrowColor:[UIColor whiteColor]];
		[(AccView *)self.accessoryView setNeedsDisplay];
	}
}
- (void)dealloc 
{
	[_showTypeImageView release];
	[_showNumberLabel release];
	[_showTitleLabel release];
	[_showGuestsLabel release];
	[_showNotesImageView release];
	[_showPicsImageView release];
	[super dealloc];
}

@end
