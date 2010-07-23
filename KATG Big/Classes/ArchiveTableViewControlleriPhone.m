//
//  ArchiveViewControlleriPhone.m
//  KATG Big
//
//  Created by Doug Russell on 7/11/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import "ArchiveTableViewControlleriPhone.h"

@implementation ArchiveTableViewControlleriPhone
@synthesize activityIndicator	=	_activityIndicator;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.separatorStyle	=	UITableViewCellSeparatorStyleNone;
	
	UIActivityIndicatorView	*	activityIndicator	=	[[UIActivityIndicatorView alloc] 
														 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	if (activityIndicator)
	{
		self.activityIndicator						=	activityIndicator;
		[activityIndicator release];
		[self.activityIndicator setHidesWhenStopped:YES];
		self.activityIndicator.center				=	self.view.center;
		[self.view addSubview:self.activityIndicator];
		[self.activityIndicator startAnimating];
	}
}

- (void)shows:(NSArray *)shows
{
	if (shows.count > 0)
	{
		[self.activityIndicator stopAnimating];
		self.tableView.separatorStyle	=	UITableViewCellSeparatorStyleSingleLine;
	}
	[super shows:shows];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	self.activityIndicator	=	nil;
}
- (void)dealloc
{
	[_activityIndicator release];
	[super dealloc];
}

@end
