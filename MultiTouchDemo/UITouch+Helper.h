// 
// Created by John Shu on 2020/7/20 22:15.
// Copyright © 2020 John Shu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITouch (Helper)

- (NSString *)touchKeyString;

- (NSComparisonResult)compareAddress:(id)obj;

@end

NS_ASSUME_NONNULL_END
