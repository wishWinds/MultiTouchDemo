// 
// Created by John Shu on 2020/7/20 22:14.
// Copyright © 2020 John Shu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultiTouchView : UIView

@property(nonatomic, assign) CGAffineTransform originalTransform;
@property(nonatomic, strong) NSMutableDictionary *touchBeginPoints;
@end

NS_ASSUME_NONNULL_END
