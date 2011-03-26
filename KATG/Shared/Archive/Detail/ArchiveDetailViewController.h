//	
//  ArchiveDetailViewController.h
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

@class Show, RoundedView;
@interface ArchiveDetailViewController : ModelViewController 
{
	NSManagedObjectID	*	showObjectID;
	Show			*	show;
	UILabel			*	showTitleLabel;
	UILabel			*	showNumberLabel;
	UILabel			*	showGuestsLabel;
	RoundedView		*	showNotesContainer;
	UITextView		*	showNotesTextView;
}

@property (nonatomic, copy)				NSManagedObjectID	*	showObjectID;
@property (nonatomic, copy)					NSNumber		*	showID;
@property (nonatomic, retain)				Show			*	show;

@property (nonatomic, retain)	IBOutlet	UILabel			*	showTitleLabel;
@property (nonatomic, retain)	IBOutlet	UILabel			*	showNumberLabel;
@property (nonatomic, retain)	IBOutlet	UILabel			*	showGuestsLabel;
@property (nonatomic, retain)	IBOutlet	RoundedView		*	showNotesContainer;
@property (nonatomic, retain)	IBOutlet	UITextView		*	showNotesTextView;

- (void)updateFields;

@end
