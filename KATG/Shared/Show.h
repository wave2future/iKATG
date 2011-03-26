//
//  Show.h
//  KATG
//
//  Created by Doug Russell on 3/2/11.
//  Copyright (c) 2011 Doug Russell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

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

@end
