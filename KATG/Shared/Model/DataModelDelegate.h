//
//  DataModelDelegate.h
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

#import <UIKit/UIKit.h>

@protocol DataModelDelegate <NSObject>
//	
//	/*UNREVISEDCOMMENT*/
//	
- (void)error:(NSError *)error display:(BOOL)display;
@optional
//	
//	/*UNREVISEDCOMMENT*/
//	
- (void)liveShowStatus:(BOOL)live;
//	
//	/*UNREVISEDCOMMENT*/
//	
- (void)nextLiveShowTime:(NSDictionary *)nextLiveShow;
//	
//	/*UNREVISEDCOMMENT*/
//	
- (void)loggedIn;
//	
//	/*UNREVISEDCOMMENT*/
//	
- (void)twitterSearchFeed:(NSArray *)tweets;
//	
//	/*UNREVISEDCOMMENT*/
//	
- (void)twitterUserFeed:(NSArray *)tweets;
//	
//	/*UNREVISEDCOMMENT*/
//	
- (void)twitterHashTagFeed:(NSArray *)tweets;
//	
//	/*UNREVISEDCOMMENT*/
//	
- (void)imageAvailableForURL:(NSString *)url;

@end
