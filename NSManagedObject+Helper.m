//
//  NSManagedObject+Helper.m
//  
//
//  Created by Derrick on 2014/4/30.
//
//

#import "NSManagedObject+Helper.h"
#import "AppDelegate.h"

#define SELF_CLASS_STRING   NSStringFromClass([self class])

@implementation NSManagedObject (Helper)

+ (instancetype)createNew
{
    NSManagedObjectContext *context = [self managedObjectContext];
    id managedObject = [NSEntityDescription insertNewObjectForEntityForName:SELF_CLASS_STRING
                                                     inManagedObjectContext:context];
    [managedObject setValue:[NSDate date] forKey:@"timestamp"];
    
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

#pragma mark - fetch

+ (id)all
{
    return [self findBy:nil value:nil limit:0];
}

+ (id)findBy:(NSString *)columnName value:(id)value
{
    return [self findBy:columnName value:value limit:0];
}

+ (id)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)max
{
    return [self findBy:columnName value:value limit:max sortBy:nil ascending:NO];
}

+ (id)findBy:(NSString *)columnName value:(id)value limit:(NSUInteger)max sortBy:(NSArray *)sortColumns ascending:(BOOL)ascending
{
    // *** create fetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:SELF_CLASS_STRING
                                   inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    // *** predicate
    if (columnName) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ == %@", columnName, value];
        [fetchRequest setPredicate:predicate];
        NSLog(@"%@", predicate);
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
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:ascending];
        [sortDescriptors addObject:sort];
    }
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchBatchSize:100];
    [fetchRequest setFetchLimit:max];
    
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

#pragma mark - private method

+ (NSManagedObjectContext *)managedObjectContext
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

- (void)didChangeValueForKey:(NSString *)key
{
    
}

@end
