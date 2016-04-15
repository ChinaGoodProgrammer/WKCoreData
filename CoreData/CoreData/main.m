//
//  main.m
//  CoreData
//
//  Created by bw on 16/3/14.
//  Copyright © 2016年 zhangquanqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"
#import "Person.h"
#import <objc/runtime.h>

int main(int argc, const char * argv[]) {

    Person *p = [[Person alloc] init];
    [p setValue:@"asdf" forKey:@"_name"];
    NSLog(@"%@", p.name);
}

int text()
{
    Person *p = [[Person alloc] init];
    p.name = @"wangkangkang";
    p.age = @"23";
    
    // 增
    [[CoreDataManager manager] addDataToPersistentStoreWithObject:p];
    // 查
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name like %@", @"*wang*"];
    NSArray *array = [[CoreDataManager manager] searchDataWithEntity:[p class] sortDescriptor:nil predicate:pre];
    for (NSManagedObject *per in array) {
        
        Person *pp = (Person *)per;
        NSLog(@"%@", pp.name);
        //        pp.name = @"kakakak";
        // 删
        //        [[CoreDataManager manager] deleteObject:per];
        // 改
        //        [[CoreDataManager manager] updataObject:per];
    }
    NSLog(@"%ld", array.count);
    
    return 0;
}
