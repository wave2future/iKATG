//
//  Event.h
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

#import <Foundation/Foundation.h>

@interface Event :  NSObject <NSCoding>
{
	NSString * Time;
	NSString * Date;
	NSDate * DateTime;
	NSNumber * ShowType;
	NSString * Details;
	NSString * EventID;
	NSString * Title;
	NSNumber * Keep;
	NSString * Day;
}

@property (nonatomic, retain) NSString * Time;
@property (nonatomic, retain) NSString * Date;
@property (nonatomic, retain) NSDate * DateTime;
@property (nonatomic, retain) NSNumber * ShowType;
@property (nonatomic, retain) NSString * Details;
@property (nonatomic, retain) NSString * EventID;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSNumber * Keep;
@property (nonatomic, retain) NSString * Day;

- (NSComparisonResult)compareUsingDateTime:(Event *)evnt;

@end


