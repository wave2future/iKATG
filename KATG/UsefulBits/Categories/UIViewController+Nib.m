//
//  UIViewController+Nib.m
//
//  Created by Doug Russell on 6/17/10.
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

#import "UIViewController+Nib.h"

@implementation UIViewController (Nib)
+ (id)loadFromNibName:(NSString *)nibNameOrNil 
				owner:(id)ownerOrNil
{
	return [self loadFromNibName:nibNameOrNil owner:ownerOrNil bundle:nil options:nil];
}
+ (id)loadFromNibName:(NSString *)nibNameOrNil 
				owner:(id)ownerOrNil 
			   bundle:(NSBundle *)bundleOrNil 
			  options:(NSDictionary *)optionsOrNil
{
	UINib	*	NIB		=	[UINib nibWithNibName:nibNameOrNil bundle:bundleOrNil];
	NSArray	*	nib		=	[NIB instantiateWithOwner:ownerOrNil options:optionsOrNil];
	return [nib objectAtIndex:0];
}
@end

@implementation UIView (Nib)
+ (id)loadFromNibName:(NSString *)nibNameOrNil 
				owner:(id)ownerOrNil
{
	return [self loadFromNibName:nibNameOrNil owner:ownerOrNil bundle:nil options:nil];
}
+ (id)loadFromNibName:(NSString *)nibNameOrNil 
				owner:(id)ownerOrNil 
			   bundle:(NSBundle *)bundleOrNil 
			  options:(NSDictionary *)optionsOrNil
{
	UINib	*	NIB		=	[UINib nibWithNibName:nibNameOrNil bundle:bundleOrNil];
	NSArray	*	nib		=	[NIB instantiateWithOwner:ownerOrNil options:optionsOrNil];
	return [nib objectAtIndex:0];
}
@end
