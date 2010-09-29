//
//  TwitterUserTableViewController_iPad.h
//	
//  Created by Doug Russell on 9/5/10.
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

#import "TwitterUserTableViewController.h"

@class MGSplitViewController;
@class TwitterDetailViewController_iPad;
@interface TwitterUserTableViewController_iPad : TwitterUserTableViewController 
{
	MGSplitViewController				*	mgsplitViewController;
	TwitterDetailViewController_iPad	*	detailViewController;
}

@property (nonatomic, retain)	IBOutlet	MGSplitViewController				*	mgsplitViewController;
@property (nonatomic, retain)	IBOutlet	TwitterDetailViewController_iPad	*	detailViewController;

- (void)selectFirstRow;

@end
