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
@class ImageScrollView;
@interface ArchivePictureDetailViewController : ModelViewController <UIScrollViewDelegate>
{
	Picture *picture;
	UIActivityIndicatorView *_activityIndicator;
	ImageScrollView *_imageView;
}

@property (nonatomic, assign) Picture *picture;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) ImageScrollView *imageView;

@end
