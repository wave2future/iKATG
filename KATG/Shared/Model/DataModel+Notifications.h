//
//  DataModel+Notifications.h
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

@interface DataModel (Notifications)

/******************************************************************************/
#pragma mark -
#pragma mark Error
#pragma mark -
/******************************************************************************/
- (void)notifyError:(NSError *)error display:(BOOL)display;
/******************************************************************************/
#pragma mark -
#pragma mark Chat
#pragma mark -
/******************************************************************************/
- (void)notifyChatLogin:(BOOL)chat;
/******************************************************************************/
#pragma mark -
#pragma mark Live Show
#pragma mark -
/******************************************************************************/
- (void)notifyLiveShowStatus:(BOOL)onAir;
- (void)notifyNextLiveShowTime:(NSDictionary *)nextLiveShow;
/******************************************************************************/
#pragma mark -
#pragma mark Archived Shows
#pragma mark -
/******************************************************************************/
- (void)notifyShowPictures:(NSArray *)pictures;
/******************************************************************************/
#pragma mark -
#pragma mark Events
#pragma mark -
/******************************************************************************/
- (void)notifyEvents:(NSArray *)events;
/******************************************************************************/
#pragma mark -
#pragma mark Twitter
#pragma mark -
/******************************************************************************/
- (void)notifyTwitterSearchFeed:(NSArray *)result;
- (void)notifyTwitterUserFeed:(NSArray *)result;
- (void)notifyTwitterHashTagFeed:(NSArray *)result;
- (void)notifyGetTwitterImageForURL:(NSString *)url;

@end
