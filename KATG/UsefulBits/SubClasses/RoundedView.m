//
//  RoundedView.m
//
//  Created by Doug Russell on 5/3/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//  

#import "RoundedView.h"
#import <QuartzCore/QuartzCore.h>

@interface RoundedView ()
- (void)setup;
@end

@implementation RoundedView
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
- (void)setup
{
	self.layer.cornerRadius = 10;
}
- (void)dealloc 
{
    [super dealloc];
}

@end
