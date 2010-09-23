//	
//	AccView.m
//	
//	Created by Doug Russell on 7/19/10.
//	Copyright 2010 Everything Solution. All rights reserved.
//	
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

#import "AccView.h"

@implementation AccView
@synthesize arrowColor;

- (void)drawRect:(CGRect)rect 
{
    // Setup context
	CGContextRef	context	=	UIGraphicsGetCurrentContext();
	
	if (self.arrowColor == nil)
		self.arrowColor	=	[UIColor whiteColor];
	
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
	[super dealloc];
}

@end
