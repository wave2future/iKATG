//
//  RoundedButton.h
//
//  Created by Doug Russell on 5/10/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//  

#import <UIKit/UIKit.h>

@interface RoundedButton : UIButton 
{
	UIColor *initialBackgroundColor;
	UIColor *highlightColor;
}

@property (nonatomic, copy) UIColor *highlightColor;

@end
