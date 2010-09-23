//
//  GradButton.m
//
//  Created by Doug Russell on 7/18/10.
//  Copyright 2010 Doug Russell. All rights reserved.
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

#import "GradButton.h"

@interface GradButton (Private)
- (void)setup;
- (void)grad;
@end

@implementation GradButton

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
	gradient					=	nil;
	self.layer.cornerRadius		=	10.0;
	self.layer.borderWidth		=	2.0;
	self.layer.masksToBounds	=	YES;
	self.layer.borderColor		=	[[UIColor colorWithRed:(CGFloat)(34.0/255.0) 
											   green:(CGFloat)(85.0/255.0) 
												blue:(CGFloat)(0.0/255.0) 
											   alpha:0.7] CGColor];
}
- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	[self.layer removeAllAnimations];
	if (gradient == nil)
	{
		gradient	=	[[CAGradientLayer layer] retain];
		gradient.colors					=	[NSArray arrayWithObjects:
											 (id)[[UIColor colorWithRed:(CGFloat)(121.0/255.0) 
																  green:(CGFloat)(171.0/255.0) 
																   blue:(CGFloat)(6.0/255.0) 
																  alpha:1.0] CGColor],
											 (id)[[UIColor colorWithRed:(CGFloat)(19.0/255.0) 
																  green:(CGFloat)(90.0/255.0) 
																   blue:(CGFloat)(0.0/255.0) 
																  alpha:1.0] CGColor],
											 (id)[[UIColor colorWithRed:(CGFloat)(52.0/255.0) 
																  green:(CGFloat)(121.0/255.0) 
																   blue:(CGFloat)(4.0/255.0) 
																  alpha:1.0] CGColor], nil];
		[self.layer insertSublayer:gradient atIndex:0];
	}
	gradient.frame					=	self.bounds;
}
#pragma mark -
#pragma mark Cleanup
#pragma mark -
- (void)dealloc
{
	[gradient release];
	[super dealloc];
}

@end
