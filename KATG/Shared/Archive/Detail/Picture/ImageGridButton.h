//
//  ImageGridButton.h
//  ImageGallery
//
//  Created by Doug Russell on 1/10/11.
//  Copyright 2011 Doug Russell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGridButton : UIButton 
{
@private
	NSInteger _index;
	UIActivityIndicatorView *_activityIndicator;
}

@property (nonatomic, readwrite) NSInteger index;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image index:(NSInteger)index target:(id)target action:(SEL)action;

@end
