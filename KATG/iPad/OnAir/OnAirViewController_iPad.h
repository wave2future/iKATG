//
//  OnAirViewController_iPad.h
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

#import <UIKit/UIKit.h>
#import "OnAirViewController.h"

@class GradButton;
@interface OnAirViewController_iPad : OnAirViewController <UITableViewDelegate>
{
	NSMutableArray	*	chatEntries;
	UITableView		*	chatTable;
	UIView			*	playerView;
	UIViewAutoresizing	feedbackResizingMask;
	GradButton		*	sendButton;
	GradButton		*	pauseButton;
	BOOL				paused;
}

@property (nonatomic, retain)			NSMutableArray	*	chatEntries;
@property (nonatomic, retain)	IBOutlet	UITableView	*	chatTable;
@property (nonatomic, retain)	IBOutlet	UIView		*	playerView;
@property (nonatomic, retain)	IBOutlet	GradButton	*	sendButton;
@property (nonatomic, retain)	IBOutlet	GradButton	*	pauseButton;

- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)pauseButtonPressed:(id)sender;
- (IBAction)logoutButtonPressed:(id)sender;

@end
