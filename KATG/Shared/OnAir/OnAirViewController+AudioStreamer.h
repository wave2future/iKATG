//
//  OnAirViewController+AudioStreamer.h
//  KATG
//
//  Created by Doug Russell on 9/16/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//

#import "OnAirViewController.h"

@interface OnAirViewController (AudioStreamer)

//	
//	Setup
//	
- (void)setupAudioAssets;
//	
//	Shoutcast
//	
- (void)_audioButtonPressed:(id)sender;
- (void)setAudioButtonImage:(UIImage *)image;
- (void)pulseButton;
- (void)destroyStreamer;
- (void)createStreamer;
//	
//	Volume Slider
//	
- (void)drawVolumeSlider;

@end
