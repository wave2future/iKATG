//
//  OnAirViewController_iPad.m
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

//#define ChatTesting

#import "OnAirViewController_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "GradButton.h"

@interface OnAirViewController_iPad ()
- (void)processFeedbackPosition;
- (void)decorateCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath;
@end

#ifdef ChatTesting
int counter = 0;
#endif

@implementation OnAirViewController_iPad
@synthesize chatEntries, chatTable, playerView, sendButton, pauseButton;

/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.chatTable.layer.borderWidth	=	1.0;
	self.chatTable.layer.borderColor	=	[[UIColor lightGrayColor] CGColor];
	self.chatTable.layer.cornerRadius	=	6.0;
	self.chatTable.layer.masksToBounds	=	YES;
	
	feedbackResizingMask				=	self.feedbackView.autoresizingMask;
	
	chatEntries							=	[[NSMutableArray alloc] init];
	
	self.pauseButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	self.pauseButton.titleLabel.textAlignment = UITextAlignmentCenter;

	
#ifdef ChatTesting
	[self addChatEntries:nil];
#endif
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.submitButton setNeedsDisplay];
	[self reloadTableView];
	if (chatEntries.count > 7 && !paused)
		[self.chatTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:chatEntries.count-1 inSection:0] 
									animated:YES 
							  scrollPosition:UITableViewScrollPositionBottom];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	self.chatEntries=	nil;
	self.chatTable	=	nil;
	self.playerView	=	nil;
	self.sendButton	=	nil;
	self.pauseButton=	nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{return YES;}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration
{
	if ([self.tabBarController.selectedViewController isEqual:self])
		[self.submitButton setNeedsDisplay];
}
/******************************************************************************/
#pragma mark -
#pragma mark Memory Management
#pragma mark -
/******************************************************************************/
- (void)dealloc
{
	[chatEntries release];
	[chatTable release];
	[playerView release];
	[sendButton release];
	[pauseButton release];
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Feedback
#pragma mark -
/******************************************************************************/
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[super textViewDidBeginEditing:textView];
	[self processFeedbackPosition];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
	[super textViewDidEndEditing:textView];
	[self performSelector:@selector(processFeedbackPosition) 
			   withObject:nil 
			   afterDelay:0.1];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self processFeedbackPosition];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self performSelector:@selector(processFeedbackPosition) 
			   withObject:nil 
			   afterDelay:0.1];
}
- (void)processFeedbackPosition
{
	CGRect	feedbackFrame	=	self.feedbackView.frame;
	if ([self.nameField isFirstResponder] ||
		[self.locationField isFirstResponder] ||
		[self.commentView isFirstResponder])
	{
		self.feedbackView.autoresizingMask	=	UIViewAutoresizingFlexibleWidth;
		CGRect	frame	=	self.feedbackView.frame;
		frame.origin.x	=	self.view.frame.size.width / 2 - frame.size.width / 2;
		frame.origin.y	=	0;
		if(!CGRectEqualToRect(feedbackFrame, frame))
		{
			[UIView beginAnimations:NULL context:NULL];
			[UIView setAnimationDuration:0.5];
			self.feedbackView.frame	=	frame;
			[UIView commitAnimations];
		}
	}
	else
	{
		self.feedbackView.autoresizingMask	=	feedbackResizingMask;
		CGRect	frame	=	self.feedbackView.frame;
		frame.origin.x	=	self.view.frame.size.width - frame.size.width;
		frame.origin.y	=	self.view.frame.size.height - frame.size.height;
		if(!CGRectEqualToRect(feedbackFrame, frame))
		{
			[UIView beginAnimations:NULL context:NULL];
			[UIView setAnimationDuration:0.8];
			self.feedbackView.frame	=	frame;
			[UIView commitAnimations];
		}
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Chat
#pragma mark -
/******************************************************************************/
- (void)addChatEntries:(NSArray *)newEntries
{
#ifdef ChatTesting
	[self performSelector:@selector(addChatEntries:) 
			   withObject:[NSArray arrayWithObjects:
						   [NSDictionary dictionaryWithObjectsAndKeys:
							@"User Name: User 1", @"user",
							[NSString stringWithFormat:@"Chat Message %d Lorem Ipsum La Tee Da Do Dorino A Da Da %@", 
							 counter + 1, [[NSDate date] description]], @"message", nil], 
						   [NSDictionary dictionaryWithObjectsAndKeys:
							@"User Name: User 2", @"user",
							[NSString stringWithFormat:@"Chat Message %d Lorem Ipsum La Tee Da Do Dorino A Da Da %@", 
							 counter + 2, [[NSDate date] description]], @"message", nil],
						   [NSDictionary dictionaryWithObjectsAndKeys:
							@"User Name: User 3", @"user",
							[NSString stringWithFormat:@"Chat Message %d Lorem Ipsum La Tee Da Do Dorino A Da Da %@", 
							 counter + 3, [[NSDate date] description]], @"message", nil], nil]
			   afterDelay:5.0];
	counter += 3;
#endif
	//	
	//	Make sure table is visible before doing any visual work
	//	
	if (![self.tabBarController.selectedViewController isEqual:self])
	{
		[chatEntries addObjectsFromArray:newEntries];
		return;
	}
	//	
	//	Add in new entries
	//	
	int	add		=	newEntries.count;
	int	count	=	chatEntries.count;
	NSMutableArray	*	paths	=	[NSMutableArray arrayWithCapacity:add];
	for (int i = count; i < count + add; i++)
	{
		[paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
	}
	[chatEntries addObjectsFromArray:newEntries];
	[chatTable insertRowsAtIndexPaths:paths
					 withRowAnimation:UITableViewRowAnimationNone];
	paths = nil;
	//	
	//	Autoscrolling to latest messages
	//	
	if (chatEntries.count > 7 && !paused)
		[self.chatTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:chatEntries.count-1 inSection:0] 
									animated:YES 
							  scrollPosition:UITableViewScrollPositionBottom];
	//	
	//	Cleanup chat history
	//	
	if (chatEntries.count > 300)
	{
		int remove = 100;
		paths	=	[NSMutableArray arrayWithCapacity:remove];
		for (int i = 0; i < remove; i++)
		{
			[paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
		[chatEntries removeObjectsInRange:NSMakeRange(0, remove)];
		[chatTable deleteRowsAtIndexPaths:paths 
						 withRowAnimation:UITableViewRowAnimationNone];
	}
}
- (IBAction)sendButtonPressed:(id)sender
{
	
}
- (IBAction)pauseButtonPressed:(id)sender
{
	paused	=	!paused;
	[self.pauseButton setTitle:(paused ? @"Resume Scrolling" : @"Pause Scrolling") forState:UIControlStateNormal];
}
- (IBAction)logoutButtonPressed:(id)sender
{
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	for (NSHTTPCookie *cookie in cookies)
	{
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
	}
	[self.chatTable reloadData];
}
- (void)loggedIn
{
	[self.chatTable reloadData];
}
/******************************************************************************/
#pragma mark -
#pragma mark Table view data source
#pragma mark -
/******************************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
	return self.chatEntries.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString	*	CellIdentifier	=	@"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
		cell							=	[[[UITableViewCell alloc] 
											  initWithStyle:UITableViewCellStyleSubtitle 
											  reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle				=	UITableViewCellSelectionStyleNone;
		//cell.textLabel.textColor		=	[UIColor whiteColor];
		//cell.detailTextLabel.textColor	=	[UIColor whiteColor];
	}
	
	[self decorateCell:cell withIndexPath:indexPath];
	
    return cell;
}
- (void)decorateCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
	cell.textLabel.text			=	[[self.chatEntries objectAtIndex:indexPath.row] objectForKey:@"user"];
	cell.detailTextLabel.text	=	[[self.chatEntries objectAtIndex:indexPath.row] objectForKey:@"message"];
}
- (void)reloadTableView
{
	if ([NSThread isMainThread])
		[self.chatTable reloadData];
	else
		[self performSelectorOnMainThread:@selector(reloadTableView) 
							   withObject:nil 
							waitUntilDone:NO];
}
/******************************************************************************/
#pragma mark -
#pragma mark Table view delegate
#pragma mark -
/******************************************************************************/
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
}

@end
