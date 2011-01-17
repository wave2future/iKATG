//
//  Picture.m
//  KATG
//
//  Created by Doug Russell on 1/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Picture.h"
#import "Show.h"


@implementation Picture
@dynamic ShowID;
@dynamic ThumbURL;
@dynamic Title;
@dynamic URL;
@dynamic Description;
@dynamic Show;

#if 0
/*
 *
 * Property methods not providing customized implementations should be removed.  
 * Optimized versions will be provided dynamically by the framework at runtime.
 *
 *
*/

- (NSString *)ShowID {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"ShowID"];
    tmpValue = [self primitiveShowID];
    [self didAccessValueForKey:@"ShowID"];
    
    return tmpValue;
}

- (void)setShowID:(NSString *)value {
    [self willChangeValueForKey:@"ShowID"];
    [self setPrimitiveShowID:value];
    [self didChangeValueForKey:@"ShowID"];
}

- (BOOL)validateShowID:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)ThumbURL {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"ThumbURL"];
    tmpValue = [self primitiveThumbURL];
    [self didAccessValueForKey:@"ThumbURL"];
    
    return tmpValue;
}

- (void)setThumbURL:(NSString *)value {
    [self willChangeValueForKey:@"ThumbURL"];
    [self setPrimitiveThumbURL:value];
    [self didChangeValueForKey:@"ThumbURL"];
}

- (BOOL)validateThumbURL:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)Title {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"Title"];
    tmpValue = [self primitiveTitle];
    [self didAccessValueForKey:@"Title"];
    
    return tmpValue;
}

- (void)setTitle:(NSString *)value {
    [self willChangeValueForKey:@"Title"];
    [self setPrimitiveTitle:value];
    [self didChangeValueForKey:@"Title"];
}

- (BOOL)validateTitle:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)URL {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"URL"];
    tmpValue = [self primitiveURL];
    [self didAccessValueForKey:@"URL"];
    
    return tmpValue;
}

- (void)setURL:(NSString *)value {
    [self willChangeValueForKey:@"URL"];
    [self setPrimitiveURL:value];
    [self didChangeValueForKey:@"URL"];
}

- (BOOL)validateURL:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)Description {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"Description"];
    tmpValue = [self primitiveDescription];
    [self didAccessValueForKey:@"Description"];
    
    return tmpValue;
}

- (void)setDescription:(NSString *)value {
    [self willChangeValueForKey:@"Description"];
    [self setPrimitiveDescription:value];
    [self didChangeValueForKey:@"Description"];
}

- (BOOL)validateDescription:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (Show *)Show {
    id tmpObject;
    
    [self willAccessValueForKey:@"Show"];
    tmpObject = [self primitiveShow];
    [self didAccessValueForKey:@"Show"];
    
    return tmpObject;
}

- (void)setShow:(Show *)value {
    [self willChangeValueForKey:@"Show"];
    [self setPrimitiveShow:value];
    [self didChangeValueForKey:@"Show"];
}

- (BOOL)validateShow:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

#endif

@end
