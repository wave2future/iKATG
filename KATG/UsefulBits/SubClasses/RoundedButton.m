//
//  RoundedButton.m
//
//  Created by Doug Russell on 5/10/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//  

#import "RoundedButton.h"
#import <QuartzCore/QuartzCore.h>

@interface RoundedButton (Private)
- (void)setup;
@end

@implementation RoundedButton
@synthesize highlightColor;

#pragma mark -
#pragma mark Init
#pragma mark -
- (id)init
{
	if (self = [super init])
	{
		[self setup];
	}
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self setup];
	}
	return self;
}
- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self setup];
	}
	return self;
}
- (void)setup
{
	highlightColor				=	nil;
	initialBackgroundColor		=	nil;
	self.layer.cornerRadius		=	10.0;
	self.layer.borderWidth		=	2.0;
	self.layer.masksToBounds	=	YES;
	self.layer.borderColor		=	[[UIColor colorWithRed:0.2 
											   green:0.4
												blue:0.2 
											   alpha:0.8] CGColor];
}
#pragma mark -
#pragma mark Touch Events
#pragma mark -
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	BOOL beginTracking = [super beginTrackingWithTouch:touch withEvent:event];
	if (initialBackgroundColor == nil)
		initialBackgroundColor = [[self backgroundColor] retain];
	if (highlightColor != nil)
		[self setBackgroundColor:highlightColor];
	return beginTracking;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[super endTrackingWithTouch:touch withEvent:event];
	[self setBackgroundColor:initialBackgroundColor];
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	// probably need a super here
	[self setBackgroundColor:initialBackgroundColor];
}
#pragma mark -
#pragma mark Cleanup
#pragma mark -
- (void)dealloc
{
	[initialBackgroundColor release];
	[highlightColor release];
	[super dealloc];
}

@end
