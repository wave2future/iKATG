//
//  DataModel+Processing.h
//	
//  Created by Doug Russell on 4/26/10.
//  Copyright Doug Russell 2010. All rights reserved.
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

#import "DataModel.h"

@class Event;
@interface DataModel (Processing)

/******************************************************************************/
#pragma mark -
#pragma mark Live Show
#pragma mark -
/******************************************************************************/
- (void)processLiveShowStatus:(id)result;
/******************************************************************************/
#pragma mark -
#pragma mark Chat
#pragma mark -
/******************************************************************************/
- (void)processChatLoginPhaseOne:(id)result 
						userName:(NSString *)userName 
						password:(NSString *)password;
- (void)processChatLoginPhaseTwo:(id)result;
- (void)processChatStartPhaseOne:(id)result;
- (void)processChatStartPhaseTwo:(id)result;
- (void)processChatPolling:(id)result;
/******************************************************************************/
#pragma mark -
#pragma mark Events
#pragma mark -
/******************************************************************************/
- (void)processEvents:(id)result;
- (NSDictionary *)dateFormatters:(NSDictionary *)event;
- (NSNumber *)detectShowType:(NSDictionary *)event;
- (BOOL)futureTest:(NSDate *)date;
- (NSArray *)currentEvents:(NSManagedObjectContext *)context;
- (Event *)hasEvent:(NSArray *)events withEventID:(NSString *)eventID;
/******************************************************************************/
#pragma mark -
#pragma mark Shows
#pragma mark -
/******************************************************************************/
- (void)processShowsList:(id)result;
- (BOOL)hasShow:(NSFetchRequest *)request forID:(NSNumber *)ID;

@end
