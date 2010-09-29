//	
//  ArchiveDetailViewController.m
//	
//  Created by Doug Russell on 5/5/10.
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

#import "ArchiveDetailViewController.h"
#import "Show.h"
#import "Guest.h"
#import "RoundedView.h"

@implementation ArchiveDetailViewController
@synthesize show;
@synthesize showTitleLabel, showNumberLabel, showGuestsLabel, showNotesTextView;
@synthesize	showNotesContainer;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self updateFields];
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.showTitleLabel		=	nil;
	self.showNumberLabel	=	nil;
	self.showGuestsLabel	=	nil;
	self.showNotesContainer	=	nil;
	self.showNotesTextView	=	nil;
}
- (void)dealloc
{
	[showTitleLabel release];
	[showNumberLabel release];
	[showGuestsLabel release];
	[showNotesContainer release];
	[showNotesTextView release];
	[super dealloc];
}
- (void)updateFields
{
	self.showTitleLabel.text	=	[self.show Title];
	self.showNumberLabel.text	=	[NSString stringWithFormat:@"Show %@", [self.show Number]];
	NSMutableString	*	guests	=	[NSMutableString string];
	int	i	=	0;
	for (Guest *guest in [self.show Guests])
	{
		i++;
		if (i == [[self.show Guests] count])
			[guests appendString:[guest Guest]];
		else
			[guests appendFormat:@"%@, ", [guest Guest]];
	}
	self.showGuestsLabel.text	=	guests;
	
	if ([self.show Notes])
		self.showNotesTextView.text	=	[self.show Notes];
}

@end
