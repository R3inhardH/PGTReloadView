//
//  ViewController.m
//  PGTReloadView
//
//  Created by Reinhard on 15/12/15.
//  Copyright © 2015 PGIT. All rights reserved.
//

#import "ViewController.h"


typedef enum {
    kReloadDirection_none = 0,
    kReloadDirection_topBottom = 1 << 0,
    kReloadDirection_leftRight = 1 << 1,
    kReloadDirection_rightLeft = 1 << 2,
    kReloadDirection_bottomTop = 1 << 3
}eReloadDirection;



@interface ViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) eReloadDirection supportedReloadDirections;

//TEst
@property (strong, nonatomic) UIImageView *topImageView;
@end

@implementation ViewController {
    CGSize _screenSize;
    eReloadDirection _scrollingDirection;
    BOOL _beginDragging;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _scrollingDirection = kReloadDirection_none;
    _screenSize = [UIScreen mainScreen].bounds.size;
    
    _beginDragging = NO;
    
    _supportedReloadDirections = (kReloadDirection_topBottom | kReloadDirection_leftRight);
//    NSLog(@"bottomTop: %d", (myEnum & kReloadDirection_bottomTop) == kReloadDirection_bottomTop);
//    NSLog(@"topBottom: %d", (myEnum & kReloadDirection_topBottom) == kReloadDirection_topBottom);
//    NSLog(@"leftRight: %d", (myEnum & kReloadDirection_leftRight) == kReloadDirection_leftRight);
//    NSLog(@"rightLeft: %d", (myEnum & kReloadDirection_rightLeft) == kReloadDirection_rightLeft);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _scrollView.scrollEnabled = YES;
    _scrollView.contentSize = CGSizeMake(_screenSize.width + 1, _screenSize.height + 1);
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock-icon.png"]];
    [_scrollView addSubview:_topImageView];
    CGRect frame = _topImageView.frame;
    frame.size.height = 40;
    frame.size.width = 40;
    frame.origin.x = _scrollView.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = -60;
    _topImageView.frame = frame;
    _topImageView.alpha = 0.0f;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIScrollView Delegate

#define kOffsetTrigger_TopBottom -80.0f
#define kOffsetTrigger_BottomTop 80.0f
#define kOffsetTrigger_LeftRight -80.0f
#define kOffsetTrigger_RightLeft 80.0f


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self isScrollViewOffsetTriggered]) {
        [UIView animateWithDuration:.3 animations:^{
            [scrollView setContentOffset:[self triggerOffsetForDirection:_scrollingDirection] animated:NO];
        }];
    }
    else {
        [UIView animateWithDuration:.3 animations:^{
            [scrollView setContentOffset:CGPointZero animated:NO];
        }];
    }
}

- (IBAction)testAction:(id)sender {
    NSLog(@"current direction: %d", _scrollingDirection);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _scrollingDirection = kReloadDirection_none;
    _scrollView.scrollEnabled = YES;
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
        _scrollView.scrollEnabled = YES;
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
        scrollView.contentOffset = [self calculateValidOffset];
        
        
        NSLog(@"alpha: %f - %f", scrollView.contentOffset.y, fabs(scrollView.contentOffset.y) / 100);
        _topImageView.alpha = fabs(scrollView.contentOffset.y)/100;
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



#define kOffsetLimit_TopBottom -100.0f
#define kOffsetLimit_BottomTop 100.0f
#define kOffsetLimit_LeftRight -100.0f
#define kOffsetLimit_RightLeft 100.0f


- (CGPoint)calculateValidOffset {
    
    CGPoint contentOffset = _scrollView.contentOffset;
    switch (_scrollingDirection) {
        case kReloadDirection_topBottom:
        {
            if (contentOffset.y <= kOffsetLimit_TopBottom) {
                return CGPointMake(0, kOffsetLimit_TopBottom);
            }
            else {
                return CGPointMake(0, contentOffset.y < 0 ? contentOffset.y : 0);
            }
            break;
        }
            
        case kReloadDirection_bottomTop:
        {
            if (contentOffset.y >= kOffsetLimit_BottomTop) {
                return CGPointMake(0, kOffsetLimit_BottomTop);
            }
            else {
                return CGPointMake(0, contentOffset.y > 0 ? contentOffset.y : 0);
            }
            break;
        }
        case kReloadDirection_leftRight:
        {
            if (contentOffset.x <= kOffsetLimit_LeftRight) {
                return CGPointMake(kOffsetLimit_LeftRight, 0);
            }
            else {
                return CGPointMake(contentOffset.x < 0 ? contentOffset.x : 0, 0);
            }
            break;
        }
        case kReloadDirection_rightLeft:
        {
            if (contentOffset.x >= kOffsetLimit_RightLeft) {
                return CGPointMake(kOffsetLimit_RightLeft, 0);
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


//- (BOOL)validateScrollViewOffsetTrigger {
//    if (_scrollingDirection == kReloadDirection_topBottom) {
//        if (_scrollView.contentOffset.y <= kOffsetTrigger_TopBottom) {
//            [UIView animateWithDuration:0.3f animations:^{
//                [_scrollView setContentOffset:CGPointMake(0, kOffsetTrigger_TopBottom) animated:NO];
//            }];
//            return YES;
//        }
//    }
//    else if (_scrollingDirection == kReloadDirection_bottomTop) {
//        if (_scrollView.contentOffset.y >= kOffsetTrigger_BottomTop) {
//            [UIView animateWithDuration:0.3f animations:^{
//                [_scrollView setContentOffset:CGPointMake(0, kOffsetTrigger_BottomTop) animated:NO];
//            }];
//            return YES;
//        }
//    }
//    if (_scrollingDirection == kReloadDirection_leftRight) {
//        if (_scrollView.contentOffset.x <= kOffsetTrigger_LeftRight) {
//            [UIView animateWithDuration:0.3f animations:^{
//                [_scrollView setContentOffset:CGPointMake(kOffsetTrigger_LeftRight, 0) animated:NO];
//            }];
//            return YES;
//        }
//    }
//    else if (_scrollingDirection == kReloadDirection_rightLeft) {
//        if (_scrollView.contentOffset.x >= kOffsetTrigger_RightLeft) {
//            [UIView animateWithDuration:0.3f animations:^{
//                [_scrollView setContentOffset:CGPointMake(kOffsetTrigger_RightLeft, 0) animated:NO];
//            }];
//            return YES;
//        }
//    }
//    return NO;
//}


- (BOOL)isScrollViewOffsetTriggered {
    switch (_scrollingDirection) {
        case kReloadDirection_topBottom:
            return _scrollView.contentOffset.y <= kOffsetTrigger_TopBottom;
            
        case kReloadDirection_bottomTop:
            return _scrollView.contentOffset.y >= kOffsetTrigger_BottomTop;
            
        case kReloadDirection_leftRight:
            return _scrollView.contentOffset.x <= kOffsetTrigger_LeftRight;
            
        case kReloadDirection_rightLeft:
            return _scrollView.contentOffset.x >= kOffsetTrigger_RightLeft;
            
        default:
            return NO;
    }
}


- (CGPoint)triggerOffsetForDirection:(eReloadDirection)reloadDirection {
    switch (reloadDirection) {
        case kReloadDirection_topBottom:
            return CGPointMake(0, kOffsetTrigger_TopBottom);
            
        case kReloadDirection_bottomTop:
            return CGPointMake(0, kOffsetTrigger_BottomTop);
            
        case kReloadDirection_leftRight:
            return CGPointMake(kOffsetTrigger_LeftRight, 0);
            
        case kReloadDirection_rightLeft:
            return CGPointMake(kOffsetTrigger_RightLeft, 0);
            
        default:
            return CGPointZero;
            break;
    }
}


- (BOOL)supportsReloadDirection:(eReloadDirection)reloadDirection {
    return (_supportedReloadDirections & reloadDirection) == reloadDirection;
}



#pragma mark - later delegate methods

- (void)reloadViewDidUpdateScrolling:(CGFloat)percentage forDirection:(eReloadDirection)reloadDirection {

}


@end
