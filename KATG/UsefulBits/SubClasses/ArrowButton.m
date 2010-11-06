//
//  ArrowButton.m
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

#import "ArrowButton.h"

@interface ArrowButton (Private)
- (void)setup;
- (void)maskGradient:(CGRect)rect;
- (void)maskBounds:(CGRect)rect;
- (void)normalGradient;
- (void)selectedGradient;
@end

@implementation ArrowButton

#pragma mark -
#pragma mark Init
#pragma mark -
- (id)init
{
	if (self = [super init])
		[self setup];
	return self;
}
- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
		[self setup];
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
//	if (self = [super initWithCoder:aDecoder])
//		[self setup];
	return self;
}
- (void)awakeFromNib
{
	[self setup];
}
- (void)setup
{
	self.titleLabel.font			=	[UIFont boldSystemFontOfSize:12.0];
	self.titleLabel.shadowColor		=	[UIColor blackColor];
	self.titleLabel.shadowOffset	=	CGSizeMake(0, -1);
	self.backgroundColor			=	[UIColor colorWithRed:(CGFloat)(36.0/255.0) 
														green:(CGFloat)(44.0/255.0) 
														 blue:(CGFloat)(36.0/255.0) 
														alpha:1.0];
	if (!gradient)
	{
		gradient			=	[[CAGradientLayer layer] retain];
		[self normalGradient];
		[self.layer insertSublayer:gradient atIndex:0];
	}
	if (!gradMask)
	{
		gradMask				=	[[CAShapeLayer layer] retain];
		[gradMask setFillColor:[[UIColor colorWithRed:(CGFloat)(0.0/255.0) 
												green:(CGFloat)(0.0/255.0) 
												 blue:(CGFloat)(0.0/255.0) 
												alpha:1.0] CGColor]];
		[gradient setMask:gradMask];
	}
	if (!layerMask)
	{
		layerMask				=	[[CAShapeLayer layer] retain];
		[layerMask setFillColor:[[UIColor colorWithRed:(CGFloat)(0.0/255.0) 
												 green:(CGFloat)(0.0/255.0) 
												  blue:(CGFloat)(0.0/255.0) 
												 alpha:1.0] CGColor]];
		[self.layer setMask:layerMask];
	}
}
#pragma mark -
#pragma mark Cleanup
#pragma mark -
- (void)dealloc
{
	[gradient release];
	[gradMask release];
	[layerMask release];
	[super dealloc];
}
#pragma mark -
#pragma mark Display
#pragma mark -
- (void)normalGradient
{
	gradient.colors		=	[NSArray arrayWithObjects:
							 (id)[[UIColor colorWithRed:(CGFloat)(115.0/255.0) 
												  green:(CGFloat)(143.0/255.0) 
												   blue:(CGFloat)(117.0/255.0) 
												  alpha:1.0] CGColor],
							 (id)[[UIColor colorWithRed:(CGFloat)(39.0/255.0) 
												  green:(CGFloat)(83.0/255.0) 
												   blue:(CGFloat)(43.0/255.0) 
												  alpha:1.0] CGColor],
							 (id)[[UIColor colorWithRed:(CGFloat)(17.0/255.0) 
												  green:(CGFloat)(65.0/255.0) 
												   blue:(CGFloat)(19.0/255.0) 
												  alpha:1.0] CGColor],
							 (id)[[UIColor colorWithRed:(CGFloat)(17.0/255.0) 
												  green:(CGFloat)(65.0/255.0) 
												   blue:(CGFloat)(19.0/255.0) 
												  alpha:1.0] CGColor], nil];
}
- (void)selectedGradient
{
	gradient.colors		=	[NSArray arrayWithObjects:
							 (id)[[UIColor colorWithRed:(CGFloat)(106.0/255.0) 
												  green:(CGFloat)(108.0/255.0) 
												   blue:(CGFloat)(106.0/255.0) 
												  alpha:1.0] CGColor],
							 (id)[[UIColor colorWithRed:(CGFloat)(27.0/255.0) 
												  green:(CGFloat)(31.0/255.0) 
												   blue:(CGFloat)(27.0/255.0) 
												  alpha:1.0] CGColor],
							 (id)[[UIColor colorWithRed:(CGFloat)(0.0/255.0) 
												  green:(CGFloat)(0.0/255.0) 
												   blue:(CGFloat)(0.0/255.0) 
												  alpha:1.0] CGColor],
							 (id)[[UIColor colorWithRed:(CGFloat)(0.0/255.0) 
												  green:(CGFloat)(0.0/255.0) 
												   blue:(CGFloat)(0.0/255.0) 
												  alpha:1.0] CGColor], nil];
}
- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	gradient.frame	=	self.bounds;
	[self maskGradient:rect];
	[self maskBounds:rect];
}
#define CornerRad 5.0
#define ArrowSize 12.0
- (void)maskGradient:(CGRect)rect
{
	//CGFloat	scale	=	[[UIScreen mainScreen] scale];
	CGFloat inset	=	1.0;
	// Mask gradient
	CGMutablePathRef	path	=	CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, CornerRad, inset);
	CGPathAddLineToPoint(path, NULL, rect.size.width - (ArrowSize + inset), inset);
	CGPathAddArc(path, NULL, rect.size.width - (ArrowSize + inset), (CornerRad + inset), CornerRad, ToRadians(-90), ToRadians(-30), false);
	CGPoint	arcEndPoint	=	CGPathGetCurrentPoint(path);
	CGPathAddLineToPoint(path, NULL, rect.size.width - inset, rect.size.height / 2.0);
	CGPathAddLineToPoint(path, NULL, arcEndPoint.x, rect.size.height - arcEndPoint.y);
	CGPathAddArc(path, NULL, rect.size.width - (ArrowSize + inset), rect.size.height - (CornerRad + inset), CornerRad, ToRadians(30), ToRadians(90), false);
	CGPathAddLineToPoint(path, NULL, rect.size.width - (CornerRad + inset), rect.size.height - inset);
	CGPathAddLineToPoint(path, NULL, (CornerRad + inset), rect.size.height - inset);
	CGPathAddArc(path, NULL, (CornerRad + inset), rect.size.height - (CornerRad + inset), CornerRad, ToRadians(90), ToRadians(180), false);
	CGPathAddLineToPoint(path, NULL, inset, (CornerRad + inset));
	CGPathAddArc(path, NULL, (CornerRad + inset), (CornerRad + inset), CornerRad, ToRadians(180), ToRadians(270), false);
	CGPathCloseSubpath(path);
	[gradMask setPath:path];
	CGPathRelease(path);
}
- (void)maskBounds:(CGRect)rect
{
	// Mask self.layer
	CGMutablePathRef	path	=	CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, CornerRad, 0);
	CGPathAddLineToPoint(path, NULL, rect.size.width - ArrowSize, 0);
	CGPathAddArc(path, NULL, rect.size.width - ArrowSize, CornerRad, CornerRad, ToRadians(-90), ToRadians(-60), false);
	CGPoint	arcEndPoint	=	CGPathGetCurrentPoint(path);
	CGPathAddLineToPoint(path, NULL, rect.size.width, rect.size.height / 2.0);
	CGPathAddLineToPoint(path, NULL, arcEndPoint.x, rect.size.height - arcEndPoint.y);
	CGPathAddArc(path, NULL, rect.size.width - ArrowSize, rect.size.height - CornerRad, CornerRad, ToRadians(60), ToRadians(90), false);
	CGPathAddLineToPoint(path, NULL, rect.size.width - CornerRad, rect.size.height);
	CGPathAddLineToPoint(path, NULL, CornerRad, rect.size.height);
	CGPathAddArc(path, NULL, CornerRad, rect.size.height - CornerRad, CornerRad, ToRadians(90), ToRadians(180), false);
	CGPathAddLineToPoint(path, NULL, 0, CornerRad);
	CGPathAddArc(path, NULL, CornerRad, CornerRad, CornerRad, ToRadians(180), ToRadians(270), false);
	CGPathCloseSubpath(path);
	[layerMask setPath:path];
	CGPathRelease(path);
}
#pragma mark -
#pragma mark Touch
#pragma mark -
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	BOOL	begin	=	[super beginTrackingWithTouch:touch withEvent:event];
	self.selected	=	YES;
	[self selectedGradient];
	return begin;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	BOOL	contin	=	[super continueTrackingWithTouch:touch withEvent:event];
	self.selected	=	YES;
	[self selectedGradient];
	return contin;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[super endTrackingWithTouch:touch withEvent:event];
	self.selected	=	NO;
	[self normalGradient];
}
- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	[super cancelTrackingWithEvent:event];
	self.selected	=	NO;
	[self normalGradient];
}

@end
