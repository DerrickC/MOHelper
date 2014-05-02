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
// Entity 則必須有兩個 column: createAt 和 updateAt


#import <CoreData/CoreData.h>

@interface NSManagedObject (Helper)

+ (instancetype)createNew;
+ (void)save;

+ (id)all;
+ (id)findBy:(NSString *)columnName value:(id)value;
+ (id)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)max;
+ (id)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)max sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending;

- (void)remove;

@end
