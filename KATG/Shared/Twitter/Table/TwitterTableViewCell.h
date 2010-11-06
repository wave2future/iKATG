//
//  TwitterTableViewCell.h
//	
//  Created by Doug Russell on 7/11/10.
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

@class CAGradientLayer;
@interface TwitterTableViewCell : UITableViewCell 
{
	UIImageView	*	_userImageView;
	UILabel		*	_userNameLabel;
	UILabel		*	_tweetTextLabel;
	UILabel		*	_timesinceLabel;
	CAGradientLayer	*	gradient;
}

@property (nonatomic, retain)	IBOutlet 	UIImageView	*	userImageView;
@property (nonatomic, retain)	IBOutlet 	UILabel		*	userNameLabel;
@property (nonatomic, retain)	IBOutlet 	UILabel		*	tweetTextLabel;
@property (nonatomic, retain)	IBOutlet 	UILabel		*	timeSinceLabel;

@end