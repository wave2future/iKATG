//
//  RoundedTextView.m
//
//  Created by Doug Russell on 3/26/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//  

#import "RoundedTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface RoundedTextView ()
- (void)setup;
@end

@implementation RoundedTextView
- (id)init
{
	if ((self = [super init])) 
	{
		[self setup];
	}
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) 
	{
		[self setup];
	}
	return self;
}
- (id)initWithFrame:(CGRect)frame 
{
	if ((self = [super initWithFrame:frame])) 
	{
		[self setup];
	}
	return self;
}
- (void)dealloc 
{
	[super dealloc];
}
- (void)setup
{
	self.layer.cornerRadius	=	10.0;
//	self.layer.borderColor	=	[[UIColor blackColor] CGColor];
//	self.layer.borderWidth	=	1.0;
}


@end
