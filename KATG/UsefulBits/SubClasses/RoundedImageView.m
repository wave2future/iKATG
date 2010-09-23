//
//  RoundedImageView.m
//  Deezly
//
//  Created by Doug Russell on 7/24/10.
//  Copyright (c) 2010 Everything Solution. All rights reserved.
//

#import "RoundedImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface RoundedImageView ()
- (void)setup;
@end

@implementation RoundedImageView

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
- (id)initWithImage:(UIImage *)image
{
	if ((self = [super initWithImage:image])) 
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
	self.layer.cornerRadius		=	6.0;
	self.layer.borderColor		=	[[UIColor blackColor] CGColor];
	self.layer.borderWidth		=	1.0;
	self.layer.masksToBounds	=	YES;
}

@end
