//
//  CoreDataManager.h
//  CoreData
//
//  Created by bw on 16/3/14.
//  Copyright © 2016年 zhangquanqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
/**
 *  单例
 */
+ (instancetype)manager;
/**
 *  增
 */
- (void)addDataToPersistentStoreWithObject:(id)object;
/**
 *  删
 */
- (void)deleteObject:(NSManagedObject *)object;
/**
 *  改
 */
- (void)updataObject:(NSManagedObject *)object;
/**
 *  查
 */
- (NSArray *)searchDataWithEntity:(Class)cls sortDescriptor:(NSSortDescriptor *)sort predicate:(NSPredicate *)predicate;

@end
