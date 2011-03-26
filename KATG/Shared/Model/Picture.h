//
//  Picture.h
//  KATG
//
//  Created by Doug Russell on 3/26/11.
//  Copyright 2011 Doug Russell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Picture : NSObject
{
	NSString *desc;
	NSString *showID;
	NSString *thumbURL;
	NSString *URL;
	NSString *title;
}

@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *showID;
@property (nonatomic, retain) NSString *thumbURL;
@property (nonatomic, retain) NSString *URL;
@property (nonatomic, retain) NSString *title;

@end
