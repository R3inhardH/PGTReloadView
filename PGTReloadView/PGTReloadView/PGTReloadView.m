//
//  PGTReloadView.m
//  PGTReloadView
//
//  Created by Reinhard on 26/12/15.
//  Copyright © 2015 PGIT. All rights reserved.
//

#import "PGTReloadView.h"


#define kDefaultMinOffset_TopBottom 80.0f
#define kDefaultMinOffset_BottomTop 80.0f
#define kDefaultMinOffset_LeftRight 80.0f
#define kDefaultMinOffset_RightLeft 80.0f


#define kDefaultMaxOffset_TopBottom 100.0f
#define kDefaultMaxOffset_BottomTop 100.0f
#define kDefaultMaxOffset_LeftRight 100.0f
#define kDefaultMaxOffset_RightLeft 100.0f


@interface PGTReloadView () <UIScrollViewDelegate>

@end



@implementation PGTReloadView {
    eReloadDirection _scrollingDirection;
    BOOL _beginDragging;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awake from nib");
    
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    _scrollingDirection = kReloadDirection_none;
    
    _beginDragging = NO;
    self.scrollEnabled = YES;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.contentSize = CGSizeMake(screenSize.width + 1, screenSize.height + 1);
}



#pragma mark - Public Methods

- (void)resetOffset {
    [UIView animateWithDuration:0.3f animations:^{
        [self setContentOffset:CGPointZero animated:NO];
    } completion:^(BOOL finished) {
        self.scrollEnabled = YES;
        if ([_reloadViewDelegate respondsToSelector:@selector(reloadViewDidResetOffset:)]) {
            [_reloadViewDelegate reloadViewDidResetOffset:self];
        }
    }];
}


#pragma mark - UIScrollView Delegate




- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self isScrollViewOffsetTriggered]) {
        [UIView animateWithDuration:.3 animations:^{
            [scrollView setContentOffset:[self triggerOffsetForDirection:_scrollingDirection] animated:NO];
        } completion:^(BOOL finished) {
            if ([_reloadViewDelegate respondsToSelector:@selector(reloadView:didTriggerForDirection:)]) {
                [_reloadViewDelegate reloadView:self didTriggerForDirection:_scrollingDirection];
            }
            _scrollingDirection = kReloadDirection_none;
            self.scrollEnabled = YES;
        }];
    }
    else {
        [UIView animateWithDuration:.3 animations:^{
            [scrollView setContentOffset:CGPointZero animated:NO];
        } completion:^(BOOL finished) {
            _scrollingDirection = kReloadDirection_none;
            self.scrollEnabled = YES;
        }];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _beginDragging = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (! CGPointEqualToPoint(scrollView.contentOffset, CGPointZero)) {
        scrollView.scrollEnabled = NO;
    }
    else {
        _scrollingDirection = kReloadDirection_none;
        self.scrollEnabled = YES;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_beginDragging) {
        _scrollingDirection = [self determineScrollingDirectionFromContentOffset:scrollView.contentOffset];
        if (_scrollingDirection != kReloadDirection_none && [self supportsReloadDirection:_scrollingDirection]) {
            _beginDragging = NO;
        }
        else {
            _scrollingDirection = kReloadDirection_none;
            scrollView.contentOffset = CGPointZero;
        }
    }
    
    if (_scrollingDirection != kReloadDirection_none) {
        CGPoint offset = [self calculateValidOffset];
        scrollView.contentOffset = offset;
        
        //delegate method didUpdateScroll
    }
}




#pragma mark - Helper Methods

- (eReloadDirection)determineScrollingDirectionFromContentOffset:(CGPoint)offset {
    if (offset.x > 0 && offset.y > 0) {
        return offset.x >= offset.y ? kReloadDirection_rightLeft : kReloadDirection_bottomTop;
    }
    if (offset.x < 0 && offset.y < 0) {
        return offset.x <= offset.y ? kReloadDirection_leftRight : kReloadDirection_topBottom;
    }
    else if (offset.x > 0 && offset.y == 0) {
        return kReloadDirection_rightLeft;
    }
    else if (offset.x < 0 && offset.y == 0) {
        return kReloadDirection_leftRight;
    }
    else if (offset.x == 0 && offset.y < 0) {
        return kReloadDirection_topBottom;
    }
    else if (offset.x == 0 && offset.y > 0) {
        return kReloadDirection_bottomTop;
    }
    return kReloadDirection_none;
}


- (CGPoint)calculateValidOffset {
    
    CGPoint contentOffset = self.contentOffset;
    switch (_scrollingDirection) {
        case kReloadDirection_topBottom:
        {
            if (contentOffset.y <= (-1) * self.maxOffsetTopBottom) {
                return CGPointMake(0, (-1) * self.maxOffsetTopBottom);
            }
            else {
                return CGPointMake(0, contentOffset.y < 0 ? contentOffset.y : 0);
            }
            break;
        }
            
        case kReloadDirection_bottomTop:
        {
            if (contentOffset.y >= self.maxOffsetBottomTop) {
                return CGPointMake(0, self.maxOffsetBottomTop);
            }
            else {
                return CGPointMake(0, contentOffset.y > 0 ? contentOffset.y : 0);
            }
            break;
        }
        case kReloadDirection_leftRight:
        {
            if (contentOffset.x <= (-1) * self.maxOffsetLeftRight) {
                return CGPointMake((-1) * self.maxOffsetLeftRight, 0);
            }
            else {
                return CGPointMake(contentOffset.x < 0 ? contentOffset.x : 0, 0);
            }
            break;
        }
        case kReloadDirection_rightLeft:
        {
            if (contentOffset.x >= self.maxOffsetRightLeft) {
                return CGPointMake(self.maxOffsetRightLeft, 0);
            }
            else {
                return CGPointMake(contentOffset.x > 0 ? contentOffset.x : 0, 0);
            }
            break;
        }
        default:
            return CGPointZero;
    }
}



//- (CGPoint)calculateValidOffset {
//    
//    CGPoint contentOffset = self.contentOffset;
//    switch (_scrollingDirection) {
//        case kReloadDirection_topBottom:
//        {
//            if (contentOffset.y <= self.maxOffsetTopBottom) {
//                return CGPointMake(0, self.maxOffsetTopBottom);
//            }
//            else {
//                return CGPointMake(0, contentOffset.y < 0 ? contentOffset.y : 0);
//            }
//            break;
//        }
//            
//        case kReloadDirection_bottomTop:
//        {
//            if (contentOffset.y >= self.maxOffsetBottomTop) {
//                return CGPointMake(0, self.maxOffsetBottomTop);
//            }
//            else {
//                return CGPointMake(0, contentOffset.y > 0 ? contentOffset.y : 0);
//            }
//            break;
//        }
//        case kReloadDirection_leftRight:
//        {
//            if (contentOffset.x <= self.maxOffsetLeftRight) {
//                return CGPointMake(self.maxOffsetLeftRight, 0);
//            }
//            else {
//                return CGPointMake(contentOffset.x < 0 ? contentOffset.x : 0, 0);
//            }
//            break;
//        }
//        case kReloadDirection_rightLeft:
//        {
//            if (contentOffset.x >= self.maxOffsetRightLeft) {
//                return CGPointMake(self.maxOffsetRightLeft, 0);
//            }
//            else {
//                return CGPointMake(contentOffset.x > 0 ? contentOffset.x : 0, 0);
//            }
//            break;
//        }
//        default:
//            return CGPointZero;
//    }
//}


- (BOOL)isScrollViewOffsetTriggered {
    switch (_scrollingDirection) {
        case kReloadDirection_topBottom:
            return self.contentOffset.y <= (-1) * self.minOffsetTopBottom;
            
        case kReloadDirection_bottomTop:
            return self.contentOffset.y >= self.minOffsetBottomTop;
            
        case kReloadDirection_leftRight:
            return self.contentOffset.x <= (-1) * self.minOffsetLeftRight;
            
        case kReloadDirection_rightLeft:
            return self.contentOffset.x >= self.minOffsetRightLeft;
            
        default:
            return NO;
    }
}


- (CGPoint)triggerOffsetForDirection:(eReloadDirection)reloadDirection {
    switch (reloadDirection) {
        case kReloadDirection_topBottom:
            return CGPointMake(0, (-1) * self.minOffsetTopBottom);
            
        case kReloadDirection_bottomTop:
            return CGPointMake(0, self.minOffsetBottomTop);
            
        case kReloadDirection_leftRight:
            return CGPointMake((-1) * self.minOffsetLeftRight, 0);
            
        case kReloadDirection_rightLeft:
            return CGPointMake(self.minOffsetRightLeft, 0);
            
        default:
            return CGPointZero;
            break;
    }
}


- (BOOL)supportsReloadDirection:(eReloadDirection)reloadDirection {
    return (_supportedReloadDirections & reloadDirection) == reloadDirection;
}


#pragma mark - Configuration parameters

- (CGFloat)minOffsetTopBottom {
    if (_minOffsetTopBottom == 0) {
        return kDefaultMinOffset_TopBottom;
    }
    return _minOffsetTopBottom;
}



- (CGFloat)minOffsetBottomTop {
    if (_minOffsetBottomTop == 0) {
        return kDefaultMinOffset_BottomTop;
    }
    return _minOffsetBottomTop;
}


- (CGFloat)minOffsetLeftRight {
    if (_minOffsetLeftRight == 0) {
        return kDefaultMinOffset_LeftRight;
    }
    return _minOffsetLeftRight;
}


- (CGFloat)minOffsetRightLeft {
    if (_minOffsetRightLeft == 0) {
        return kDefaultMinOffset_RightLeft;
    }
    return _minOffsetRightLeft;
}


- (CGFloat)maxOffsetBottomTop {
    if (_maxOffsetBottomTop == 0) {
        return kDefaultMaxOffset_BottomTop;
    }
    return _maxOffsetBottomTop;
}


- (CGFloat)maxOffsetTopBottom {
    if (_maxOffsetTopBottom == 0) {
        return kDefaultMaxOffset_TopBottom;
    }
    return _maxOffsetTopBottom;
}


- (CGFloat)maxOffsetLeftRight {
    if (_maxOffsetLeftRight == 0) {
        return kDefaultMaxOffset_LeftRight;
    }
    return _maxOffsetLeftRight;
}


- (CGFloat)maxOffsetRightLeft {
    if (_maxOffsetRightLeft == 0) {
        return kDefaultMaxOffset_RightLeft;
    }
    return _maxOffsetRightLeft;
}


@end
