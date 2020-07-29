// 
// Created by John Shu on 2020/7/20 22:14.
// Copyright © 2020 John Shu. All rights reserved.
//

#import "MultiTouchView.h"
#import "UITouch+Helper.h"

@implementation MultiTouchView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userInteractionEnabled = true;
    self.multipleTouchEnabled = true;
    self.originalTransform = CGAffineTransformIdentity;
    self.touchBeginPoints = [NSMutableDictionary dictionary];
}
 
- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches {
    NSArray *sortedTouches = [[touches allObjects] sortedArrayUsingSelector:@selector(compareAddress:)];
    NSInteger numTouches = [sortedTouches count];
    
    // No touches
    if (numTouches == 0) {
        return CGAffineTransformIdentity;
    }

    // Single touch
    if (numTouches == 1) {
        UITouch *touch = [sortedTouches objectAtIndex:0];
        CGPoint beginPoint = [self.touchBeginPoints[touch.touchKeyString] CGPointValue];
        CGPoint currentPoint = [touch locationInView:self.superview];
        return CGAffineTransformMakeTranslation(currentPoint.x - beginPoint.x, currentPoint.y - beginPoint.y);
    }

    // If two or more touches, go with the first two (sorted by address)
    UITouch *touch1 = [sortedTouches objectAtIndex:0];
    UITouch *touch2 = [sortedTouches objectAtIndex:1];

    CGPoint beginPoint1 = [self.touchBeginPoints[touch1.touchKeyString] CGPointValue];
    CGPoint currentPoint1 = [touch1 locationInView:self.superview];
    CGPoint beginPoint2 = [self.touchBeginPoints[touch2.touchKeyString] CGPointValue];
    CGPoint currentPoint2 = [touch2 locationInView:self.superview];

    double layerX = self.center.x;
    double layerY = self.center.y;
    
    double x1 = beginPoint1.x - layerX;
    double y1 = beginPoint1.y - layerY;
    double x2 = beginPoint2.x - layerX;
    double y2 = beginPoint2.y - layerY;
    double x3 = currentPoint1.x - layerX;
    double y3 = currentPoint1.y - layerY;
    double x4 = currentPoint2.x - layerX;
    double y4 = currentPoint2.y - layerY;
    
    // Solve the system:
    //   [a b t1, -b a t2, 0 0 1] * [x1, y1, 1] = [x3, y3, 1]
    //   [a b t1, -b a t2, 0 0 1] * [x2, y2, 1] = [x4, y4, 1]
    
    double D = (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2);
    if (D < 0.1) {
        return CGAffineTransformMakeTranslation(x3-x1, y3-y1);
    }

    double a = (y1-y2)*(y3-y4) + (x1-x2)*(x3-x4);
    double b = (y1-y2)*(x3-x4) - (x1-x2)*(y3-y4);
    double tx = (y1*x2 - x1*y2)*(y4-y3) - (x1*x2 + y1*y2)*(x3+x4) + x3*(y2*y2 + x2*x2) + x4*(y1*y1 + x1*x1);
    double ty = (x1*x2 + y1*y2)*(-y4-y3) + (y1*x2 - x1*y2)*(x3-x4) + y3*(y2*y2 + x2*x2) + y4*(y1*y1 + x1*x1);
    
    return CGAffineTransformMake(a/D, -b/D, b/D, a/D, tx/D, ty/D);
}


- (void)updateOriginalTransformForTouches:(NSSet *)touches {
    if ([touches count] > 0) {
        CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:touches];
        self.transform = CGAffineTransformConcat(self.originalTransform, incrementalTransform);
        self.originalTransform = self.transform;
    }
}

- (void)removeTouchesFromCache:(NSSet *)touches {
    for (UITouch *touch in touches) {
        [self.touchBeginPoints removeObjectForKey:touch.touchKeyString];
    }
}

- (void)cacheBeginPointForTouches:(NSSet *)touches {
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.superview];
        self.touchBeginPoints[touch.touchKeyString] = [NSValue valueWithCGPoint:point];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSMutableSet *oldTouches = [[event touchesForView:self] mutableCopy];
    [oldTouches minusSet:touches];
    
    if ([oldTouches count] > 0) {
        [self updateOriginalTransformForTouches:oldTouches];
        [self cacheBeginPointForTouches:oldTouches];
    }
    
    [self cacheBeginPointForTouches:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:[event touchesForView:self]];
    self.transform = CGAffineTransformConcat(self.originalTransform, incrementalTransform);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateOriginalTransformForTouches:[event touchesForView:self]];
    [self removeTouchesFromCache:touches];
    
    NSMutableSet *remainingTouches = [[event touchesForView:self] mutableCopy];
    [remainingTouches minusSet:touches];
    [self cacheBeginPointForTouches:remainingTouches];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


@end
