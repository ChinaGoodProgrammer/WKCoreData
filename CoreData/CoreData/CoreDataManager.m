//
//  CoreDataManager.m
//  CoreData
//
//  Created by bw on 16/3/14.
//  Copyright © 2016年 zhangquanqun. All rights reserved.
//

#import "CoreDataManager.h"
#import <objc/runtime.h>

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    static CoreDataManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[CoreDataManager alloc] init];
        [manager initializeCoreData];
        
    });
    
    return manager;
}
/**
 *  初始化CoreData
 */
- (void)initializeCoreData
{
    // 构建SQLite数据库文件的路径
    NSURL *dosc = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [dosc URLByAppendingPathComponent:@"CoreData.sqlite"];
    NSLog(@"%@", storeURL.absoluteString);
    
    // 添加持久化存储库，这里使用SQLite作为存储库
    NSError *error = nil;
    NSPersistentStore *store = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (store == nil) {
        [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];
    }
    // 设置上下文的数据库协调者
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
}
/**
 *  增
 */
- (void)addDataToPersistentStoreWithObject:(id)object
{
    if (object == nil) {
        return;
    }
    NSString *className = NSStringFromClass([object class]);
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:self.managedObjectContext];
    
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([object class], &count);
    for (NSInteger i = 0; i < count; i++) {
        
        Ivar var = ivarList[i];
        NSString *propertyName = [NSString stringWithUTF8String:ivar_getName(var)];
        // 去除下划线
        NSString *key = [propertyName substringFromIndex:1];
        SEL sel = NSSelectorFromString(key);
        // 进行赋值
        [managedObject setValue:[object performSelector:sel] forKey:key];
    }
    free(ivarList);
    [self saveContext];
}
/**
 *  删
 */
- (void)deleteObject:(NSManagedObject *)object
{
    // 传入需要删除的对象
    [self.managedObjectContext deleteObject:object];
    // 将数据同步到数据库中
    [self saveContext];
}
/**
 *  改
 */
- (void)updataObject:(NSManagedObject *)object
{
    [self.managedObjectContext refreshObject:object mergeChanges:YES];
    [self saveContext];
}
/**
 *  查
 */
- (NSArray *)searchDataWithEntity:(Class)cls sortDescriptor:(NSSortDescriptor *)sort predicate:(NSPredicate *)predicate
{
    // 初始化一个查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 设置要查询的实体
    NSString *entityName = NSStringFromClass(cls);
    request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
//    request.sortDescriptors = [NSArray arrayWithObject:sort];
    request.predicate = predicate;
    
    // 执行请求
    NSError *error = nil;
    NSArray *objs = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", error.localizedDescription];
    }
    // 遍历数据
//    for (NSManagedObject *obj in objs) {
//        NSLog(@"name=%@", [obj valueForKey:@"name"]);
//    }
    return objs;
}
#pragma mark - Core Data Saving support

- (void)saveContext {
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {

            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            if (DEBUG) {
               abort();
            }
        }
    }
}

#pragma mark - getter Method

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        // 传入模型对象，初始化NSPersistentStoreCoordinator
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    }
    return _persistentStoreCoordinator;
}
- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        // 从应用程序包中加载模型文件
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return _managedObjectModel;
}
- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        // 初始化上下文，设置persistentStoreCoordinator属性
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    return _managedObjectContext;
}
@end
