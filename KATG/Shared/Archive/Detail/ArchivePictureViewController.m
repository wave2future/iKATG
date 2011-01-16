//	
//  ArchivePictureViewController.m
//	
//  Created by Doug Russell on 5/5/10.
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

#import "ArchivePictureViewController.h"
#import "Show.h"
#import "Picture.h"
#import "OrderedDictionary.h"
#import "ImageButton.h"

@implementation ArchivePictureViewController
@synthesize show;

- (id)init
{
	if ((self = [super init]))
	{
		buttons = [[OrderedDictionary alloc] init];
	}
	return self;
}
/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)loadView
{
	[super loadView];
	UIScrollView *aView = [[UIScrollView alloc] initWithFrame:ScreenDimensionsInPoints()];
	aView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
							  UIViewAutoresizingFlexibleHeight);
	aView.backgroundColor = [UIColor colorWithRed:(CGFloat)(112.0/255.0) 
											green:(CGFloat)(174.0/255.0) 
											 blue:(CGFloat)(36.0/255.0) 
											alpha:1.0];
	self.view = aView;
	[aView release];
	self.navigationItem.title = @"Pictures";
}
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	NSSet	*	pictures	=	[show Pictures];
	if (pictures.count == 0)
		[model showPictures:[self.show.ID stringValue]];
	else 
		[self drawThumbGrid:pictures];
}
- (void)drawThumbGrid:(NSSet *)pictures
{
	CGFloat		scale	=	1.0;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
		scale			=	[[UIScreen mainScreen] scale];
	int pictureWidth = 120 / scale;
	
	int pictureCount = pictures.count;
	int gridUnitWidth = ((int)self.view.frame.size.width) / pictureWidth;
	int gridUnitHeight = pictureCount / gridUnitWidth;
	((UIScrollView *)self.view).contentSize = CGSizeMake(self.view.frame.size.width, ((CGFloat)gridUnitHeight) * ((CGFloat)pictureWidth));
	[[buttons allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[buttons removeAllObjects];
	int i = 0;
	CGFloat leftSideOffset = (self.view.frame.size.width - gridUnitWidth * ((CGFloat)pictureWidth)) / 2.0;
	CGFloat topOffest = 20.0;
	for (Picture *picture in pictures)
	{
		int row = i / gridUnitWidth;
		int col = i % gridUnitWidth;
		
		ImageButton * button = [ImageButton buttonWithType:UIButtonTypeCustom];
		button.backgroundColor = [UIColor blueColor];
		button.frame = CGRectMake(leftSideOffset + ((CGFloat)pictureWidth) * ((CGFloat)col), topOffest + ((CGFloat)pictureWidth) * ((CGFloat)row), ((CGFloat)pictureWidth) - 10.0, ((CGFloat)pictureWidth) - 10.0);
		button.picture = picture;
		[button addTarget:self action:@selector(thumbnailSelected:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:button];
		[buttons setObject:button forKey:picture.ThumbURL];
		
		i++;
	}
}
- (void)thumbnailSelected:(ImageButton *)sender
{
	NSLog(@"%@", sender.picture.URL);
}
- (void)imageAvailableForURL:(NSString *)url
{
	
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
}
/******************************************************************************/
#pragma mark -
#pragma mark Memory Management
#pragma mark -
/******************************************************************************/
- (void)dealloc 
{
	[buttons release];
    [super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Model Delegate Methods
#pragma mark -
/******************************************************************************/
- (void)showPicturesAvailable:(NSString *)ID
{
	NSSet	*	pictures	=	[show Pictures];
	for (Picture *picture in pictures)
	{
		NSLog(@"%@", picture.URL);
		NSLog(@"%@", picture.ThumbURL);
	}
}

@end
