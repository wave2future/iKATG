//	
//	Tweet.m
//	ESTwitterViewer
//	
//	Created by Doug Russell on 9/5/10.
//	Copyright 2010 Doug Russell. All rights reserved.
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

#import "Tweet.h"

@implementation Tweet
@synthesize	From;
@synthesize	To;
@synthesize	Date;
@synthesize	Text;
@synthesize	WebViewText;
@synthesize	ImageURL;

- (void)dealloc
{
	[From release];
	[To release];
	[Date release];
	[Text release];
	[WebViewText release];
	[ImageURL release];
	[super dealloc];
}

@end