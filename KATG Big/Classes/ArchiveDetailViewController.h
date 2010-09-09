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

@class Show;
@interface ArchiveDetailViewController : UIViewController 
<DataModelDelegate>
{
	DataModel		*	model;
	Show			*	show;
	UILabel			*	showTitleLabel;
	UILabel			*	showNumberLabel;
	UILabel			*	showGuestsLabel;
	RoundedView		*	showNotesContainer;
	UITextView		*	showNotesTextView;
	UIButton		*	playButton;
}

@property (nonatomic, assign)				Show			*	show;
@property (nonatomic, retain)	IBOutlet	UILabel			*	showTitleLabel;
@property (nonatomic, retain)	IBOutlet	UILabel			*	showNumberLabel;
@property (nonatomic, retain)	IBOutlet	UILabel			*	showGuestsLabel;
@property (nonatomic, retain)	IBOutlet	RoundedView		*	showNotesContainer;
@property (nonatomic, retain)	IBOutlet	UITextView		*	showNotesTextView;
@property (nonatomic, retain)	IBOutlet	UIButton		*	playButton;

- (IBAction)playButtonPressed:(id)sender;

@end