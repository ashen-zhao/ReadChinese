//
//  AppDelegate.h
//  ReadChinese
//
//  Created by Ashen on 15/12/29.
//  Copyright © 2015年 Ashen. All rights reserved.
//

#import "ASConvertor.h"

static ASConvertor * instance=nil;

@implementation ASConvertor

+ (ASConvertor*)getInstance
{
    @synchronized(self) {
        if (instance==nil) {
            instance=[[ASConvertor alloc] init];
        }
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *filrPath = [[NSBundle mainBundle] pathForResource:@"ts.tab" ofType:nil];
        NSString *data = [NSString stringWithContentsOfFile:filrPath encoding:NSUTF8StringEncoding error:NULL];
        NSMutableArray *chars = [[NSMutableArray alloc] initWithCapacity:[data length]];
        for (int i=0; i < [data length]; i++) {
            NSString *ichar  = [NSString stringWithFormat:@"%C", [data characterAtIndex:i]];
            [chars addObject:ichar];
        }
        
        ts = [NSMutableDictionary new];
        st = [NSMutableDictionary new];
        
        for (int i = 0; i < [chars count] ; i = i + 2){
            NSString *one = [chars objectAtIndex:i];
            NSString *two = [chars objectAtIndex:(i + 1)];
            [st setObject:one forKey:two];
            [ts setObject:two forKey:one];
        }
    }
    return self;
}

- (NSString*)t2s:(NSString*)string;
{
    NSString *result = @"";
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:[string length]];
    for (int i=0; i < [string length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%C", [string characterAtIndex:i]];
        [tmpArray addObject:ichar];
    }
    for (NSString *s in tmpArray){
        if ([ts objectForKey:s]){
            result = [NSString stringWithFormat:@"%@%@", result, [ts objectForKey:s]];
        } else {
            result = [NSString stringWithFormat:@"%@%@", result, s];
        }
    }
    return result;
}

- (NSString*)s2t:(NSString*)string
{
    NSString *result = @"";
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:[string length]];
    for (int i=0; i < [string length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%C", [string characterAtIndex:i]];
        [tmpArray addObject:ichar];
    }
    for (NSString *s in tmpArray){
        if ([st objectForKey:s]){
            result = [NSString stringWithFormat:@"%@%@", result, [st objectForKey:s]];
        } else {
            result = [NSString stringWithFormat:@"%@%@", result, s];
        }
    }
    return result;
}

@end
