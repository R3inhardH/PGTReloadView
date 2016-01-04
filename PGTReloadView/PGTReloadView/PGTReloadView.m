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

@property (assign, nonatomic) eReloadDirection scrollingDirection;

@end



@implementation PGTReloadView {
    BOOL _beginDragging;
    BOOL _isTriggered;
    BOOL _isHandlingDelegate;
    UIView *_currentReloadControlIcon;
}
@synthesize minOffsetTopBottom = _minOffsetTopBottom;
@synthesize minOffsetBottomTop = _minOffsetBottomTop;
@synthesize minOffsetLeftRight = _minOffsetLeftRight;
@synthesize minOffsetRightLeft = _minOffsetRightLeft;
@synthesize maxOffsetTopBottom = _maxOffsetTopBottom;
@synthesize maxOffsetBottomTop = _maxOffsetBottomTop;
@synthesize maxOffsetLeftRight = _maxOffsetLeftRight;
@synthesize maxOffsetRightLeft = _maxOffsetRightLeft;



- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awake from nib");
    
    [self setupReloadView];
//    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(test) userInfo:nil repeats:YES];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupReloadView];
    }
    return self;
}


- (id)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
    }
    return self;
}


- (void)setupReloadView {
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.scrollingDirection = kReloadDirection_none;
    _isTriggered = NO;
    _beginDragging = NO;
    self.scrollEnabled = YES;
//    self.clipsToBounds = NO;
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object: nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(scrollingDirection)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self && [keyPath isEqualToString:NSStringFromSelector(@selector(scrollingDirection))]) {
//        NSInteger oldC = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        eReloadDirection newC = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        if (newC != kReloadDirection_none) {
            BOOL isCustomView = NO;
            if ([self.reloadDatasource respondsToSelector:@selector(shouldShowCustomReloadIconForDirection:)]) {
                isCustomView = [self.reloadDatasource shouldShowCustomReloadIconForDirection:_scrollingDirection];
            }
            if (!isCustomView) {
                _isHandlingDelegate = YES;
                _currentReloadControlIcon = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                _currentReloadControlIcon.hidden = NO;
//                [(UIActivityIndicatorView *)_currentReloadControlIcon startAnimating];
                [self addReloadIconAsSubview:_currentReloadControlIcon];
            }
            else {
                
            }
        }
        
    }
    else if (object == self && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
        CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        self.contentSize = CGSizeMake(newFrame.size.width + 1, newFrame.size.height + 1);
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)deviceOrientationDidChange:(NSNotification *)notification {
    //Obtain current device orientation
    NSLog(@"contentoffset: %@", NSStringFromCGPoint(self.contentOffset));

//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSLog(@"contentSize: %@", NSStringFromCGSize(self.contentSize));
    NSLog(@"frame: %@", NSStringFromCGRect(self.frame));
    
    self.contentSize = CGSizeMake(self.frame.size.width + 1, self.frame.size.height + 1);
    
    if (_isTriggered) {
        [self setContentOffset:[self triggerOffsetForDirection:self.scrollingDirection] animated:NO];
    }
    else {
        self.scrollingDirection = kReloadDirection_none;
    }
}


#pragma mark - Public Methods

- (void)resetOffset {
    _isTriggered = NO;
    [UIView animateWithDuration:0.3f animations:^{
        [self setContentOffset:CGPointZero animated:NO];
    } completion:^(BOOL finished) {
        self.scrollEnabled = YES;
        if ([self.reloadDelegate respondsToSelector:@selector(reloadViewDidResetOffset:)]) {
            [self.reloadDelegate reloadViewDidResetOffset:self];
        }
        [_currentReloadControlIcon removeFromSuperview];
    }];
}



#pragma mark - UIScrollView Delegate


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self isScrollViewOffsetTriggered]) {
        _isTriggered = YES;
        [UIView animateWithDuration:.3 animations:^{
            [scrollView setContentOffset:[self triggerOffsetForDirection:self.scrollingDirection] animated:NO];
        } completion:^(BOOL finished) {
            self.scrollEnabled = NO;
            if ([self.reloadDelegate respondsToSelector:@selector(reloadView:didTriggerForDirection:)]) {
                [self.reloadDelegate reloadView:self didTriggerForDirection:self.scrollingDirection];
            }
            if (_isHandlingDelegate) {
                [(UIActivityIndicatorView *)_currentReloadControlIcon startAnimating];
            }
            
        }];
    }
    else {
        [UIView animateWithDuration:.3 animations:^{
            [scrollView setContentOffset:CGPointZero animated:NO];
        } completion:^(BOOL finished) {
            self.scrollingDirection = kReloadDirection_none;
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
        self.scrollingDirection = kReloadDirection_none;
        self.scrollEnabled = YES;
        [_currentReloadControlIcon removeFromSuperview];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_beginDragging) {
        self.scrollingDirection = [self determineScrollingDirectionFromContentOffset:scrollView.contentOffset];
        if (self.scrollingDirection != kReloadDirection_none && [self supportsReloadDirection:self.scrollingDirection]) {
            _beginDragging = NO;
        }
        else {
            self.scrollingDirection = kReloadDirection_none;
            scrollView.contentOffset = CGPointZero;
        }
    }
    
    if (self.scrollingDirection != kReloadDirection_none) {
        CGPoint offset = [self calculateValidOffset];
        scrollView.contentOffset = offset;
        if (_isHandlingDelegate) {
            [self performReloadIconAnimationForOffset:offset];
        }
        else {
            //delegate
        }
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
    switch (self.scrollingDirection) {
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


- (BOOL)isScrollViewOffsetTriggered {
    switch (self.scrollingDirection) {
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



#pragma mark - Private Delegate Methods

- (void)addReloadIconAsSubview:(UIView *)reloadIcon {
    [self addSubview:reloadIcon];
    CGRect frame = reloadIcon.frame;
    switch (_scrollingDirection) {
        case kReloadDirection_topBottom:
            frame.origin.x = (self.frame.size.width / 2) - (reloadIcon.frame.size.width / 2);
            frame.origin.y = ((-1) * ((self.maxOffsetTopBottom / 2) + (reloadIcon.frame.size.height / 2))) + (self.maxOffsetTopBottom - self.minOffsetTopBottom);
            break;

        case kReloadDirection_bottomTop:
            frame.origin.x = (self.frame.size.width / 2) - (reloadIcon.frame.size.width / 2);
            frame.origin.y = (self.frame.size.height + (self.maxOffsetBottomTop / 2) - (reloadIcon.frame.size.height / 2)) - (self.maxOffsetBottomTop - self.minOffsetBottomTop);
            break;

        case kReloadDirection_leftRight:
            frame.origin.x = ((-1) * ((self.maxOffsetLeftRight / 2) + (reloadIcon.frame.size.width / 2)) + (self.maxOffsetLeftRight - self.minOffsetLeftRight));
            frame.origin.y = (self.frame.size.height / 2) - (reloadIcon.frame.size.height / 2);
            break;
            
        case kReloadDirection_rightLeft:
            frame.origin.x = (self.frame.size.width + (self.maxOffsetRightLeft / 2) - (reloadIcon.frame.size.width / 2)) - (self.maxOffsetRightLeft - self.minOffsetLeftRight);
            frame.origin.y = (self.frame.size.height / 2) - (reloadIcon.frame.size.height / 2);
            break;
            
        default:
            break;
    }
    reloadIcon.frame = frame;
}


- (void)performReloadIconAnimationForOffset:(CGPoint)offset {
    switch (_scrollingDirection) {
        case kReloadDirection_topBottom:
            _currentReloadControlIcon.alpha = fabs(self.contentOffset.y) / self.minOffsetTopBottom;
            break;
            
        case kReloadDirection_bottomTop:
            _currentReloadControlIcon.alpha = fabs(self.contentOffset.y) / self.minOffsetBottomTop;

            break;
            
        case kReloadDirection_leftRight:
            _currentReloadControlIcon.alpha = fabs(self.contentOffset.x) / self.minOffsetLeftRight;

            break;
            
        case kReloadDirection_rightLeft:
            _currentReloadControlIcon.alpha = fabs(self.contentOffset.x) / self.minOffsetRightLeft;

            break;
            
        default:
            break;
    }
}



#pragma mark - Configuration Getters & Setters

- (void)setMinOffsetTopBottom:(CGFloat)minOffsetTopBottom {
    if (minOffsetTopBottom < 0) {
        _minOffsetTopBottom = -1 * minOffsetTopBottom;
    }
    else {
        _minOffsetTopBottom = minOffsetTopBottom;
    }
}


- (CGFloat)minOffsetTopBottom {
    if (_minOffsetTopBottom == 0) {
        return kDefaultMinOffset_TopBottom;
    }
    return _minOffsetTopBottom;
}


- (void)setMinOffsetBottomTop:(CGFloat)minOffsetBottomTop {
    if (minOffsetBottomTop < 0) {
        _minOffsetBottomTop = -1 * minOffsetBottomTop;
    }
    else {
        _minOffsetBottomTop = minOffsetBottomTop;
    }
}


- (CGFloat)minOffsetBottomTop {
    if (_minOffsetBottomTop == 0) {
        return kDefaultMinOffset_BottomTop;
    }
    return _minOffsetBottomTop;
}


- (void)setMinOffsetLeftRight:(CGFloat)minOffsetLeftRight {
    if (minOffsetLeftRight < 0) {
        _minOffsetLeftRight = -1 * minOffsetLeftRight;
    }
    else {
        _minOffsetLeftRight = minOffsetLeftRight;
    }
}


- (CGFloat)minOffsetLeftRight {
    if (_minOffsetLeftRight == 0) {
        return kDefaultMinOffset_LeftRight;
    }
    return _minOffsetLeftRight;
}



- (void)setMinOffsetRightLeft:(CGFloat)minOffsetRightLeft {
    if (minOffsetRightLeft < 0) {
        _minOffsetRightLeft = -1 * minOffsetRightLeft;
    }
    else {
        _minOffsetRightLeft = minOffsetRightLeft;
    }
}


- (CGFloat)minOffsetRightLeft {
    if (_minOffsetRightLeft == 0) {
        return kDefaultMinOffset_RightLeft;
    }
    return _minOffsetRightLeft;
}


- (void)setMaxOffsetTopBottom:(CGFloat)maxOffsetTopBottom {
    if (maxOffsetTopBottom < 0) {
        _maxOffsetTopBottom = -1 * maxOffsetTopBottom;
    }
    else {
        _maxOffsetTopBottom = maxOffsetTopBottom;
    }
}


- (CGFloat)maxOffsetBottomTop {
    if (_maxOffsetBottomTop == 0) {
        return kDefaultMaxOffset_BottomTop;
    }
    return _maxOffsetBottomTop;
}


- (void)setMaxOffsetBottomTop:(CGFloat)maxOffsetBottomTop {
    if (maxOffsetBottomTop < 0) {
        _maxOffsetBottomTop = -1 * maxOffsetBottomTop;
    }
    else {
        _maxOffsetBottomTop = maxOffsetBottomTop;
    }
}


- (CGFloat)maxOffsetTopBottom {
    if (_maxOffsetTopBottom == 0) {
        return kDefaultMaxOffset_TopBottom;
    }
    return _maxOffsetTopBottom;
}


- (void)setMaxOffsetLeftRight:(CGFloat)maxOffsetLeftRight {
    if (maxOffsetLeftRight < 0) {
        _maxOffsetLeftRight = -1 * maxOffsetLeftRight;
    }
    else {
        _maxOffsetLeftRight = maxOffsetLeftRight;
    }
}


- (CGFloat)maxOffsetLeftRight {
    if (_maxOffsetLeftRight == 0) {
        return kDefaultMaxOffset_LeftRight;
    }
    return _maxOffsetLeftRight;
}


- (void)setMaxOffsetRightLeft:(CGFloat)maxOffsetRightLeft {
    if (maxOffsetRightLeft < 0) {
        _maxOffsetRightLeft = -1 * maxOffsetRightLeft;
    }
    else {
        _maxOffsetRightLeft = maxOffsetRightLeft;
    }
}


- (CGFloat)maxOffsetRightLeft {
    if (_maxOffsetRightLeft == 0) {
        return kDefaultMaxOffset_RightLeft;
    }
    return _maxOffsetRightLeft;
}




- (void)test {
    NSLog(@"currentDirection: %d", self.scrollingDirection);
}





@end
