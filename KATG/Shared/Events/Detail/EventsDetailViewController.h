//
//  EventsDetailViewController.h
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
#import "ModelViewController.h"

@class Event;
@interface EventsDetailViewController : ModelViewController 
{
	Event		*	event;
	
	UIView		*	webContainerView;
	UIWebView	*	webView;
	
	UILabel		*	titleLabel;
	UILabel		*	dateTimeLabel;
}

@property (nonatomic, assign)          Event		*	event;

@property (nonatomic, retain) IBOutlet UIView		*	webContainerView;
@property (nonatomic, retain) IBOutlet UIWebView	*	webView;

@property (nonatomic, retain) IBOutlet UILabel		*	titleLabel;
@property (nonatomic, retain) IBOutlet UILabel		*	dateTimeLabel;

- (void)updateFields;

@end