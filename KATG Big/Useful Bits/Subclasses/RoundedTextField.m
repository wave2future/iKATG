//
//  RoundedTextField.m
//
//  Created by Doug Russell on 5/11/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//  

#import "RoundedTextField.h"
#import <QuartzCore/QuartzCore.h>

@interface RoundedTextField ()
- (void)setup;
@end

@implementation RoundedTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self setup];
	}
	return self;
}
- (id)initWithFrame:(CGRect)aRect
{
	if (self = [super initWithFrame:aRect])
	{
		[self setup];
	}
	return self;
}
- (void)setup
{
	self.layer.cornerRadius = 4;
	// need to inset cursor a few pixels
}
- (void)dealloc
{
	[super dealloc];
}

@end
