//
//  TwitterTableViewCell.m
//	
//  Created by Doug Russell on 7/11/10.
//  Copyright Doug Russell 2010. All rights reserved.
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

#import "TwitterTableViewCell.h"
#import <Quartzcore/QuartzCore.h>
#import "AccView.h"

@interface TwitterTableViewCell ()
- (void)setup;
@end

@implementation TwitterTableViewCell
@synthesize	userImageView = _userImageView;
@synthesize	userNameLabel = _userNameLabel;
@synthesize	tweetTextLabel = _tweetTextLabel;
@synthesize	timeSinceLabel = _timesinceLabel;

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
	UIView			*	view		=	[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
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
	self.selectedBackgroundView		=	view;
	[view release]; view			=	nil;
	
}
- (void)awakeFromNib
{
	//	
	//	
	//	
	[self setup];
	//	
	//	
	//	
	self.userImageView.layer.borderColor	=	[[UIColor blackColor] CGColor];
	self.userImageView.layer.borderWidth	=	1.0;
	self.userImageView.layer.shadowColor	=	[[UIColor blackColor] CGColor];
	self.userImageView.layer.shadowOffset	=	CGSizeMake(2.0, 2.0);
	self.userImageView.layer.shadowOpacity	=	0.6;
	self.userImageView.layer.shouldRasterize=	YES;
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect	gradFrame	=	self.backgroundView.bounds;
	gradient.frame		=	gradFrame;
}
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
	[_userImageView release];
	[_userNameLabel release];
	[_tweetTextLabel release];
	[_timesinceLabel release];
	[gradient release];
	[super dealloc];
}

@end
