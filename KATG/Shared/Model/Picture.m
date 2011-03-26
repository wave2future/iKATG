//
//  Picture.m
//  KATG
//
//  Created by Doug Russell on 3/26/11.
//  Copyright 2011 Doug Russell. All rights reserved.
//

#import "Picture.h"

@implementation Picture
@synthesize desc;
@synthesize showID;
@synthesize thumbURL;
@synthesize URL;
@synthesize title;

- (void)dealloc
{
	[desc release];
	[showID release];
	[thumbURL release];
	[URL release];
	[title release];
	[super dealloc];
}

@end
