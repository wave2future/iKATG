//
//  ModalWebViewController_iPhone.m
//
//  Created by Doug Russell on 5/6/10.
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

#import "ModalWebViewController_iPhone.h"

@implementation ModalWebViewController_iPhone

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	float	osVer	=	[[[UIDevice currentDevice] systemVersion] floatValue];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
	{
		if (osVer >= 4.0 && osVer < 4.2)
			self.adBanner.currentContentSizeIdentifier	=	ADBannerContentSizeIdentifier480x32;
		//else if (osVer >= 4.2)
		//	self.adBanner.currentContentSizeIdentifier	=	ADBannerContentSizeIdentifierLandscape;
	}
    else
	{
		if (osVer >= 4.0 && osVer < 4.2)
			self.adBanner.currentContentSizeIdentifier	=	ADBannerContentSizeIdentifier320x50;
		//else if (osVer >= 4.2)
		//	self.adBanner.currentContentSizeIdentifier	=	ADBannerContentSizeIdentifierPortrait;
	}
}

@end