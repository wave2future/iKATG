//
//  ImageGridButton.m
//  ImageGallery
//
//  Created by Doug Russell on 1/10/11.
//  Copyright 2011 Doug Russell. All rights reserved.
//

#import "ImageGridButton.h"

@implementation ImageGridButton
@synthesize index = _index;
@synthesize activityIndicator = _activityIndicator;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image index:(NSInteger)index target:(id)target action:(SEL)action
{
	if ((self = [super initWithFrame:frame]))
	{
		self.autoresizingMask = UIViewAutoresizingNone;
		self.backgroundColor = [UIColor lightGrayColor];
		self.index = index;
		[self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.center = self.center;
		activityIndicator.hidesWhenStopped = YES;
		self.activityIndicator = activityIndicator;
		[self addSubview:self.activityIndicator];
		[activityIndicator release];
		
		[self setImage:image forState:UIControlStateNormal];
	}
	return self;
}
- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
	if (image)
		[self.activityIndicator stopAnimating];
	else
		[self.activityIndicator startAnimating];
	
	[super setImage:image forState:state];
}
- (void)dealloc
{
	[_activityIndicator release];
	[super dealloc];
}

@end
