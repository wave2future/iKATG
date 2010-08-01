//
//  RoundedLabel.m
//  Deezly
//
//  Created by Doug Russell on 7/24/10.
//  Copyright (c) 2010 Everything Solution. All rights reserved.
//

#import "RoundedLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface RoundedLabel ()
- (void)setup;
@end

@implementation RoundedLabel

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
	self.layer.cornerRadius =	6;
	//self.layer.borderColor	=	[[UIColor blackColor] CGColor];
	//self.layer.borderWidth	=	1.0;
}
- (void)dealloc 
{
    [super dealloc];
}

@end
