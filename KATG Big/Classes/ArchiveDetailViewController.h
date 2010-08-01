//
//  ArchiveDetailViewController.h
//  KATG Big
//
//  Created by Doug Russell on 7/21/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "Rounded.h"

@class Show, MPMoviePlayerController;
@interface ArchiveDetailViewController : UIViewController 
<DataModelDelegate>
{
	DataModel		*	model;
	Show			*	show;
	UILabel			*	showTitleLabel;
	UILabel			*	showNumberLabel;
	UILabel			*	showGuestsLabel;
	UITextView		*	showNotesTextView;
	UIButton		*	playButton;
	MPMoviePlayerController	*	player;
}

@property (nonatomic, assign)				Show			*	show;
@property (nonatomic, retain)	IBOutlet	UILabel			*	showTitleLabel;
@property (nonatomic, retain)	IBOutlet	UILabel			*	showNumberLabel;
@property (nonatomic, retain)	IBOutlet	UILabel			*	showGuestsLabel;
@property (nonatomic, retain)	IBOutlet	UITextView		*	showNotesTextView;
@property (nonatomic, retain)	IBOutlet	UIButton		*	playButton;
@property (nonatomic, retain)				MPMoviePlayerController	*	player;

@end
