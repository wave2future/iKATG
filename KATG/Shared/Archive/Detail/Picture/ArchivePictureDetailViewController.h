//
//  ArchivePictureDetailViewController.h
//  KATG
//
//  Created by Doug Russell on 1/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModelViewController.h"

@class Picture;
@interface ArchivePictureDetailViewController : ModelViewController 
{
	Picture *picture;
	UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, assign) Picture *picture;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

@end
