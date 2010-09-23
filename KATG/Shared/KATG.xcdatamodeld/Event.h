//
//  Event.h
//  KATG
//
//  Created by Doug Russell on 9/16/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Event :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Time;
@property (nonatomic, retain) NSString * Date;
@property (nonatomic, retain) NSDate * DateTime;
@property (nonatomic, retain) NSNumber * ShowType;
@property (nonatomic, retain) NSString * Details;
@property (nonatomic, retain) NSString * EventID;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSNumber * Keep;
@property (nonatomic, retain) NSString * Day;

@end



