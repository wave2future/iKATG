//
//  Show.h
//  KATG
//
//  Created by Doug Russell on 1/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Picture;

@interface Show : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * ForumThread;
@property (nonatomic, retain) NSNumber * HasNotes;
@property (nonatomic, retain) NSString * Guests;
@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSNumber * PDT;
@property (nonatomic, retain) NSString * URL;
@property (nonatomic, retain) NSNumber * Number;
@property (nonatomic, retain) NSNumber * TV;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * Notes;
@property (nonatomic, retain) NSString * Quote;
@property (nonatomic, retain) NSNumber * PictureCount;
@property (nonatomic, retain) NSSet* Pictures;

@end
