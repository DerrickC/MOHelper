//
//  NSManagedObject+Helper.h
//
//
//  參考 from Wuufone on 12/6/23.
//  Created by Derrick on 2014/4/30.
//
//

// === 使用說明 ===
//
// core data 的建立方式為 Xcode 預設的實作方式
// 許多實作已經建立在 AppDelegate 裡面
// Entity 需有兩個 column: createdAt 和 updatedAt


#import <CoreData/CoreData.h>

@protocol MOHelperProtocol <NSObject>
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@end

@interface NSManagedObject (Helper)

+ (instancetype)createNew;
+ (void)save;


+ (instancetype)randomOne;
+ (NSArray *)random:(NSUInteger)count;

+ (NSArray *)all;
+ (NSArray *)findBy:(NSString *)columnName value:(id)value;
+ (NSArray *)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)max;
+ (NSArray *)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)max sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending;

+ (NSArray *)findBy:(NSArray *)columnNames values:(NSArray *)values;
+ (NSArray *)findBy:(NSArray *)columnNames values:(NSArray *)values limit:(NSUInteger)max;
+ (NSArray *)findBy:(NSArray *)columnNames values:(NSArray *)values limit:(NSUInteger)max sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending;

+ (NSArray *)findByPredicate:(NSPredicate *)predicate;
+ (NSArray *)findByPredicate:(NSPredicate *)predicate limit:(NSUInteger)max;
+ (NSArray *)findByPredicate:(NSPredicate *)predicate limit:(NSUInteger)max sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending;

- (void)remove;

@end
