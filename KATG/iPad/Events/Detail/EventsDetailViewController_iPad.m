//
//  EventsDetailViewController_iPad.m
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

#import "EventsDetailViewController_iPad.h"
#import "ModalWebViewController_iPad.h"

@implementation EventsDetailViewController_iPad
@synthesize mgsplitViewController;

- (void)openRequest:(NSURLRequest *)request
{
	ModalWebViewController_iPad	*	viewController	=	
	[[ModalWebViewController_iPad alloc] init];
	viewController.request					=	request;
	viewController.modalPresentationStyle	=	UIModalPresentationFormSheet;
	viewController.modalTransitionStyle		=	UIModalTransitionStyleFlipHorizontal;
	[self.mgsplitViewController presentModalViewController:viewController animated:YES];
	[viewController release];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	mgsplitViewController	=	nil;
}
- (void)dealloc
{
	[mgsplitViewController release];
	[super dealloc];
}

@end
