//
//  NSManagedObject+Helper.m
//  
//
//  Created by Derrick on 2014/4/30.
//
//

#import "NSManagedObject+Helper.h"
#import "AppDelegate.h"

#define SELF_CLASS_STRING                             NSStringFromClass([self class])

#if !__has_feature(objc_arc)
#error MOHelper is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

@implementation NSManagedObject (Helper)

+ (void) load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(objectContextWillSave:)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:nil];
}

#pragma mark - CRUD

+ (instancetype)createNew
{
    NSManagedObjectContext *context = [self managedObjectContext];
    id managedObject = [NSEntityDescription insertNewObjectForEntityForName:SELF_CLASS_STRING
                                                     inManagedObjectContext:context];
    if ([managedObject respondsToSelector:@selector(createdAt)]) {
        [managedObject setValue:[NSDate date] forKey:@"createdAt"];
    } else {
        NSLog(@"\n*****************\n***** ERROR *****\n*****************\nmanaged object 沒有 createdAt 參數");
    }
    
    return managedObject;
}

+ (void)save
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}

- (void)remove
{
    [[self managedObjectContext] deleteObject:self];
    [[self class] save];
}

+ (void)removeAll
{
    NSArray *all = [self all];
    
    for (NSInteger i=0; i<all.count; i++) {
        id object = [all objectAtIndex:i];
        [[self managedObjectContext] deleteObject:object];
    }
    
    [self save];
}

+ (instancetype)randomOne
{
    // create fetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:SELF_CLASS_STRING
                                   inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // random offset
    NSError *error;
    NSUInteger entityCount = [[self managedObjectContext] countForFetchRequest:fetchRequest
                                                                           error:&error];
    // Get random value between 0 ~ entityCount
    int randomOffset = arc4random() % entityCount;
    [fetchRequest setFetchLimit:1];
    [fetchRequest setFetchOffset:randomOffset];
    
    // FETCH!
    NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return [results firstObject];
}

+ (NSArray *)random:(NSUInteger)count
{
    NSMutableArray *randomObjects = [[NSMutableArray alloc] init];
    
    // create fetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:SELF_CLASS_STRING
                                   inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // random offset
    NSError *error;
    NSUInteger entityCount = [[self managedObjectContext] countForFetchRequest:fetchRequest
                                                                         error:&error];
    
    // random offsets
    NSMutableArray *randomOffsets = [[NSMutableArray alloc] init];
    while (randomOffsets.count < count) {
        int randomOffset = arc4random() % entityCount;
        NSNumber *offsetNumber = [NSNumber numberWithInt:randomOffset];
        
        if ([randomOffsets indexOfObject:offsetNumber] == NSNotFound) {
            [randomOffsets addObject:offsetNumber];
        }
    }
    
    // pick 4 objects
    for (NSNumber *offset in randomOffsets) {
        [fetchRequest setFetchLimit:1];
        [fetchRequest setFetchOffset:[offset integerValue]];
        // FETCH!
        NSArray *results = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        [randomObjects addObject:[results firstObject]];
    }
    
    return randomObjects;
}

+ (NSArray *)all
{
    return [self findBy:nil value:nil limit:0];
}

+ (NSArray *)findBy:(NSString *)columnName value:(id)value
{
    return [self findBy:columnName value:value limit:0];
}

+ (NSArray *)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)max
{
    return [self findBy:columnName value:value limit:max sortBy:nil ascending:NO];
}

+ (NSArray *)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)max sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending
{
    // *** predicate
    NSPredicate *predicate;
    if (columnName) {
        predicate = [NSPredicate predicateWithFormat:@"self.%@ == %@", columnName, value];
    }
    
    // *** sort conditions
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    if (sortColumns) {
        for (NSString *sortColumn in sortColumns) {
            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:sortColumn ascending:ascending];
            [sortDescriptors addObject:sort];
            NSLog(@"condition: %@", sortColumn);
        }
    } else {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:ascending];
        [sortDescriptors addObject:sort];
    }
    
    return [self fetchResultsByPredicate:predicate sortDescriptors:sortDescriptors maxCount:max];
}

#pragma mark - 多條件

+ (NSArray *)findBy:(NSArray *)columnNames values:(NSArray *)values
{
    return [self findBy:columnNames values:values limit:0];
}

+ (NSArray *)findBy:(NSArray *)columnNames values:(NSArray *)values limit:(NSUInteger)max
{
    return [self findBy:columnNames values:values limit:max sortBy:nil ascending:NO];
}

+ (NSArray *)findBy:(NSArray *)columnNames values:(NSArray *)values limit:(NSUInteger)max sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending
{
    NSString *predicateStr = @"";
    for (NSInteger i=0; i<columnNames.count; i++) {
        NSString *columnName = columnNames[i];
        id value = values[i];
        NSString *and;
        if (i != 0) {
            and = @" AND ";
        }
        predicateStr = [NSString stringWithFormat:@"%@%@self.%@ == %@", predicateStr, and, columnName, value];
    }
    
    // *** predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@", predicateStr];
    
    // *** sort conditions
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    if (sortColumns) {
        for (NSString *sortColumn in sortColumns) {
            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:sortColumn ascending:ascending];
            [sortDescriptors addObject:sort];
            NSLog(@"condition: %@", sortColumn);
        }
    } else {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:ascending];
        [sortDescriptors addObject:sort];
    }
    
    return [self fetchResultsByPredicate:predicate sortDescriptors:sortDescriptors maxCount:max];
}

#pragma mark - 需要自己在外部產生 predicate 來搜尋

+ (NSArray *)findByPredicate:(NSPredicate *)predicate
{
    return [self findByPredicate:predicate limit:0];
}

+ (NSArray *)findByPredicate:(NSPredicate *)predicate limit:(NSUInteger)max
{
    return [self findByPredicate:predicate limit:0 sortBy:nil ascending:NO];
}

+ (NSArray *)findByPredicate:(NSPredicate *)predicate limit:(NSUInteger)max sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending
{
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    if (sortColumns) {
        for (NSString *sortColumn in sortColumns) {
            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:sortColumn ascending:ascending];
            [sortDescriptors addObject:sort];
            NSLog(@"condition: %@", sortColumn);
        }
    } else {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:ascending];
        [sortDescriptors addObject:sort];
    }
    
    return [self fetchResultsByPredicate:predicate sortDescriptors:sortDescriptors maxCount:max];
}

//+ (NSArray *)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)max sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending
//{
//    // *** create fetchRequest
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription
//                                   entityForName:SELF_CLASS_STRING
//                                   inManagedObjectContext:[self managedObjectContext]];
//    [fetchRequest setEntity:entity];
//    
//    // *** predicate
//    if (columnName) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ == %@", columnName, value];
//        [fetchRequest setPredicate:predicate];
//        NSLog(@"%@", predicate);
//    }
//    
//    // *** sort conditions
//    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
//    if (sortColumns) {
//        for (NSString *sortColumn in sortColumns) {
//            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:sortColumn ascending:ascending];
//            [sortDescriptors addObject:sort];
//            NSLog(@"condition: %@", sortColumn);
//        }
//    } else {
//        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:ascending];
//        [sortDescriptors addObject:sort];
//    }
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    [fetchRequest setFetchBatchSize:100];
//    [fetchRequest setFetchLimit:max];
//    
//    NSFetchedResultsController *fetchedResultsController =
//    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//                                        managedObjectContext:[self managedObjectContext]
//                                          sectionNameKeyPath:nil
//                                                   cacheName:nil];
//    NSError *error;
//    BOOL fetchResult = [fetchedResultsController performFetch:&error];
//    
//    // get result
//    if (fetchResult) {
//        return fetchedResultsController.fetchedObjects;
//    }
//    
//    return nil;
//}

#pragma mark - private method

+ (NSManagedObjectContext *)managedObjectContext
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

+ (void)objectContextWillSave:(NSNotification *)notification
{
    NSManagedObjectContext* context = [notification object];
    NSSet* allModified = [context.insertedObjects setByAddingObjectsFromSet:context.updatedObjects];
//    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [self class]];
//    NSSet* modifiable = [allModified filteredSetUsingPredicate: predicate];
//    [modifiable makeObjectsPerformSelector: @selector(setLastModified:) withObject: [NSDate date]];
    [allModified makeObjectsPerformSelector:@selector(setLastModified:)
                                 withObject:[NSDate date]];
}

- (void)setLastModified:(id)object
{
    NSDate *nowDate = (NSDate *)object;
    
    if ([self respondsToSelector:@selector(updatedAt)]) {
        [self setValue:nowDate forKey:@"updatedAt"];
    } else {
        NSLog(@"\n*****************\n***** ERROR *****\n*****************\nmanaged object 沒有 updatedAt 參數");
    }
}

+ (NSArray *)fetchResultsByPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors maxCount:(NSUInteger)maxCount
{
    // *** create fetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:SELF_CLASS_STRING
                                   inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // *** predicate
    [fetchRequest setPredicate:predicate];
    
    // *** sort conditions
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:100];
    [fetchRequest setFetchLimit:maxCount];
    
    NSFetchedResultsController *fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[self managedObjectContext]
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    NSError *error;
    BOOL fetchResult = [fetchedResultsController performFetch:&error];
    
    // get result
    if (fetchResult) {
        return fetchedResultsController.fetchedObjects;
    }
    
    return nil;
}

@end
