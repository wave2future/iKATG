//
//  ImageGridTableViewCell.h
//  ImageGallery
//
//  Created by Doug Russell on 1/9/11.
//  Copyright 2011 Doug Russell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGridTableViewCell : UITableViewCell 
{
@private
	NSInteger _row;
	NSArray *_images;
	NSMutableArray *_imageViews;
}

+ (CGFloat)cellHeight;
- (void)setImages:(NSArray *)images 
		   forRow:(NSInteger)row 
	   withTarget:(id)target 
		   action:(SEL)action;
- (NSInteger)row;

@end
