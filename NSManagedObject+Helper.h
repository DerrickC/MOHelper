//
//  NSManagedObject+Helper.h
//
//
//  參考 from 武峯 江 on 12/6/23.
//  Created by Derrick on 2014/4/30.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Helper)

+ (instancetype)createNew;
+ (void)save;

+ (id)all;
+ (id)findBy:(NSString *)columnName value:(id)value;
+ (id)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)maxValue;
+ (id)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)maxValue sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending;

- (void)remove;

@end
