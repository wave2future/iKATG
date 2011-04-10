//
//  ImageGridTableViewCell.m
//  ImageGallery
//
//  Created by Doug Russell on 1/9/11.
//  Copyright 2011 Doug Russell. All rights reserved.
//

#import "ImageGridTableViewCell.h"
#import "ImageGridButton.h"
//#import <QuartzCore/QuartzCore.h>
#import "Picture.h"
#import "DataModel.h"

@interface ImageGridTableViewCell ()
+ (CGFloat)imageSideDimension;
@end

@implementation ImageGridTableViewCell

+ (CGFloat)cellHeight
{
	return 102 / 1;//[[UIScreen mainScreen] scale];
}
+ (CGFloat)imageSideDimension
{
	return [ImageGridTableViewCell cellHeight] - 2;
}
- (id)initWithStyle:(UITableViewCellStyle)style 
	reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:UITableViewCellStyleDefault 
					 reuseIdentifier:reuseIdentifier]))
	{
		_imageViews = [[NSMutableArray alloc] init];
		self.selectionStyle = UITableViewCellEditingStyleNone;
		self.backgroundColor = [UIColor blackColor];
		self.contentView.backgroundColor = [UIColor blackColor];
	}
	return self;
}
- (void)dealloc 
{
	[_images release];
	[_imageViews release];
    [super dealloc];
}
- (void)setImages:(NSArray *)images forRow:(NSInteger)row withTarget:(id)target action:(SEL)action
{
	//	
	//	Store New Images Array
	//	
	[images retain];
	[_images release];
	_images = images;
	//	
	//	Store row (not using now)
	//	
	_row = row;
	//	
	//	Clear all existing imageViews
	//	
	[_imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_imageViews removeAllObjects];
	//	
	//	Make New Imageviews
	//	
	for (int i = 0; i < _images.count; i++)
	{
		UIImage *image = [[DataModel sharedDataModel] imageForURL:[(Picture *)[_images objectAtIndex:i] thumbURL]];
		CGFloat sideDimension = [ImageGridTableViewCell imageSideDimension];
		ImageGridButton *button = [[ImageGridButton alloc] initWithFrame:CGRectMake(0, 1, sideDimension, sideDimension) 
																   image:image 
																   index:((row * 3) + i) 
																  target:target 
																  action:action];
		NSLog(@"Row %d Image Number %d", row, ((row * 3) + i));
		if (button)
		{
			[_imageViews addObject:button];
			[self.contentView addSubview:button];
			[button release];
		}
	}
	[self setNeedsLayout];
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	//	
	//	Align images from left to right across cell,
	//	with the whole block centered and 2 pixels
	//	between views
	//	
	CGFloat spaceBetweenImageViews = 2;
	CGFloat xOffset = (self.contentView.frame.size.width - (_imageViews.count * [ImageGridTableViewCell imageSideDimension])) / 2;
	xOffset -= ((_imageViews.count - 1) * spaceBetweenImageViews) / 2;
	if (xOffset < 0)
		xOffset = 0;
	for (int i = 0; i < _imageViews.count; i++)
	{
		UIView *imageView = [_imageViews objectAtIndex:i];
		CGRect frame = imageView.frame;
		frame.origin.x = xOffset;
		imageView.frame = frame;
		xOffset	+= frame.size.width + spaceBetweenImageViews;
	}
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	[super setSelected:selected animated:animated];
}
- (NSInteger)row
{
	return _row;
}

@end
