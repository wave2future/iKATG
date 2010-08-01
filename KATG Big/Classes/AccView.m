//
//  AccView.m
//  KATG Big
//
//  Created by Doug Russell on 7/19/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import "AccView.h"

@implementation AccView
@synthesize arrowColor;

- (void)drawRect:(CGRect)rect 
{
    // Setup context
	CGContextRef	context	=	UIGraphicsGetCurrentContext();
	
	if (self.arrowColor == nil)
		self.arrowColor	=	[UIColor darkGrayColor];
	
	CGContextSetStrokeColorWithColor(context, [self.arrowColor CGColor]);
	
	CGFloat	x		=	rect.size.width / 2 + 4.5;
	CGFloat	y		=	rect.size.height / 2;
	
	CGFloat radius	=	4.5;
	CGFloat width	=	3.0;
	
	CGContextMoveToPoint(context, x - radius, y - radius);
	CGContextAddLineToPoint(context, x, y);
	CGContextAddLineToPoint(context, x - radius, y + radius);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextSetLineJoin(context, kCGLineJoinMiter);
	CGContextSetLineWidth(context, width);
	
	// Draw it
	CGContextStrokePath(context);
}

- (void)dealloc
{
	[arrowColor release];
}

@end
