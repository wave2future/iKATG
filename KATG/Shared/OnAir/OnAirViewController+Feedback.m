//
//  OnAirViewController+Feedback.m
//  KATG
//
//  Created by Doug Russell on 9/16/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//

#import "OnAirViewController+Feedback.h"

@implementation OnAirViewController (Feedback)

- (void)sendFeedback
{
	NSString	*	comment		=	[commentView text];
	if (comment == nil ||
		[comment isEqualToString:@""] ||
		[comment isEqualToString:@"Feedback"])
		return;
	NSString	*	name		=	[nameField text];
	if (name == nil)
		name = @"";
	NSString	*	location	=	[locationField text];
	if (location == nil)
		location				=	@"";
	[model feedback:name 
		   location:location 
			comment:comment];
	[commentView setText:@""];
	[commentView resignFirstResponder];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if ([[textView text] isEqualToString:@"Feedback"])
	{
		[textView setTextColor:[UIColor blackColor]];
		[textView setText:@""];
	}
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
	if ([[textView text] isEqualToString:@""])
	{
		[textView setTextColor:[UIColor colorWithRed:0.71 green:0.71 blue:0.71 alpha:1.0]];
		[textView setText:@"Feedback"];
	}
}
- (void)loadDefaults
{
	NSUserDefaults	*	userDefaults	=	[NSUserDefaults standardUserDefaults];
	NSString		*	name			=	[userDefaults objectForKey:@"Name"];
	[nameField setText:name];
	NSString		*	location		=	[userDefaults objectForKey:@"Location"];
	[locationField setText:location];
	NSString		*	comment			=	[userDefaults objectForKey:@"Feedback"];
	if (comment && ![comment isEqualToString:@"Feedback"])
	{
		[commentView setTextColor:[UIColor blackColor]];
		[commentView setText:comment];
	}
	if (!streamer)
	{
		if ([userDefaults boolForKey:@"Playing"] && [model isConnected]) 
			[self audioButtonPressed:nil];
		else if ([userDefaults boolForKey:@"Playing"] && ![model isConnected]) 
			playOnConnection			=	YES;
	}
}
- (void)writeDefaults  
{
	NSUserDefaults	*	userDefaults	=	[NSUserDefaults standardUserDefaults];
	if ([[nameField text] length] > 0) 
		[userDefaults setObject:[nameField text] forKey:@"Name"];
	if ([[locationField text] length] > 0) 
		[userDefaults setObject:[locationField text] forKey:@"Location"];
	if ([[commentView text] length] > 0) 
		[userDefaults setObject:[commentView text] forKey:@"Comment"];
	if (streamer) 
		[userDefaults setBool:YES forKey:@"Playing"];
	else
		[userDefaults setBool:NO forKey:@"Playing"];
	[userDefaults synchronize];
}

@end
