// 
// Created by John Shu on 2020/7/20 22:15.
// Copyright © 2020 John Shu. All rights reserved.
//

#import "UITouch+Helper.h"

@implementation UITouch (Helper)
- (NSComparisonResult)compareAddress:(id)obj {
    if ((__bridge void *)self < (__bridge void *)obj) {
        return NSOrderedAscending;
    } else if ((__bridge void *)self == (__bridge void *)obj) {
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}

- (NSString *)touchKeyString {
    return [NSString stringWithFormat:@"%p", self];
}
@end
