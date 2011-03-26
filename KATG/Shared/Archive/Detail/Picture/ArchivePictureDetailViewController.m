//
//  ArchivePictureDetailViewController.m
//  KATG
//
//  Created by Doug Russell on 1/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ArchivePictureDetailViewController.h"
#import "Picture.h"
#import "ImageScrollView.h"

@implementation ArchivePictureDetailViewController
@synthesize picture;
@synthesize activityIndicator = _activityIndicator;
@synthesize imageView = _imageView;

/******************************************************************************/
#pragma mark -
#pragma mark Setup Cleanup
#pragma mark -
/******************************************************************************/
- (void)dealloc 
{
	picture = nil;
	[_activityIndicator release];
	[_imageView release];
    [super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)loadView 
{
	UIScrollView *scrollView = [[UIScrollView alloc] init];
	scrollView.delegate = self;
	scrollView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
								   UIViewAutoresizingFlexibleRightMargin |
								   UIViewAutoresizingFlexibleBottomMargin |
								   UIViewAutoresizingFlexibleLeftMargin |
								   UIViewAutoresizingFlexibleWidth |
								   UIViewAutoresizingFlexibleHeight);
	self.view = scrollView;
	[scrollView release];
	
	ImageScrollView *imageView = [[ImageScrollView alloc] init];
	imageView.autoresizingMask = (/*UIViewAutoresizingFlexibleTopMargin |
								  UIViewAutoresizingFlexibleRightMargin |
								  UIViewAutoresizingFlexibleBottomMargin |
								  UIViewAutoresizingFlexibleLeftMargin |*/
								  UIViewAutoresizingFlexibleWidth |
								  UIViewAutoresizingFlexibleHeight);
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.imageView = imageView;
//	self.view = imageView;
	[self.view addSubview:self.imageView];
	[imageView release];
	
	UIActivityIndicatorView *aView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	self.activityIndicator = aView;
	[aView release];
	
	UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
	[self.navigationItem setRightBarButtonItem:barButton];
	[barButton release];
}
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self.activityIndicator startAnimating];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	self.navigationController.toolbar.tintColor = [DefaultValues defaultToolbarTint];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (picture.title && 
		(picture.title.length != 0))
	{
		[self.navigationController setToolbarHidden:NO animated:NO];
		
		CGSize size = self.navigationController.toolbar.frame.size;
		UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width - 20.0, size.height)];
		description.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		description.backgroundColor = [UIColor clearColor];
		description.text = picture.title;
		description.adjustsFontSizeToFitWidth = YES;
		description.minimumFontSize = 10.0;
		description.textAlignment = UITextAlignmentCenter;
		description.textColor = [UIColor whiteColor];
		UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:description];
		self.navigationController.toolbar.items = [NSArray arrayWithObjects:
												   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																								  target:nil 
																								  action:nil] autorelease], 
												   item, 
												   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																								  target:nil 
																								  action:nil] autorelease], 
												   nil];
		[description release];
		[item release];
	}
	
	UIImage *img = [model imageForURL:picture.URL];
	if (img)
	{
		[self.activityIndicator stopAnimating];
		[self.imageView displayImage:img];
	}
}
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.navigationController.toolbar.items = nil;
	[self.navigationController setToolbarHidden:YES];
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.activityIndicator = nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model
#pragma mark -
/******************************************************************************/
- (void)imageAvailableForURL:(NSString *)url
{
	if ([NSThread isMainThread])
	{
		UIImage *img = [model imageForURL:picture.URL];
		if (img)
		{
			[self.activityIndicator stopAnimating];
			//[(UIImageView *)[self view] setImage:img];
			[self.imageView displayImage:img];
		}
	}
	else
		[self performSelectorOnMainThread:@selector(imageAvailableForURL:) 
							   withObject:url 
							waitUntilDone:NO];
}
/******************************************************************************/
#pragma mark -
#pragma mark Scroll View Delegate
#pragma mark -
/******************************************************************************/
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.imageView;
}

@end
