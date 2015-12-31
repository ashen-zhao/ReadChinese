//
//  AppDelegate.h
//  ReadChinese
//
//  Created by Ashen on 15/12/29.
//  Copyright © 2015年 Ashen. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface ASConvertor : NSObject{
    NSMutableDictionary *ts, *st;
}

// Create Instance for the class
+ (ASConvertor*)getInstance;

// Convert Tradictional chinese to Simple chinese
- (NSString*)t2s:(NSString*)string;

// convert Simple chinese to Tradictional chinese
- (NSString*)s2t:(NSString*)string;

@end
