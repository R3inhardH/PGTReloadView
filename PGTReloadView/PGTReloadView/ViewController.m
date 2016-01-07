//
//  TestViewController.m
//  PGTReloadView
//
//  Created by Reinhard on 26/12/15.
//  Copyright © 2015 PGIT. All rights reserved.
//

#import "ViewController.h"
#import "PGTReloadView.h"

#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

@interface ViewController () <PGTReloadViewDelegate, PGTReloadViewDatasource>

@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView2;


@property (weak, nonatomic) IBOutlet PGTReloadView *reloadView;

@end

@implementation ViewController {
    float _topOffset;
    BOOL _animateTop;
    BOOL _animateLeft;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.topButton setTitle:@"TOP: Disabled" forState:UIControlStateNormal];
    [self.topButton setTitle:@"TOP: Enabled" forState:UIControlStateSelected];
    [self.bottomButton setTitle:@"BOTTOM: Disabled" forState:UIControlStateNormal];
    [self.bottomButton setTitle:@"BOTTOM: Enabled" forState:UIControlStateSelected];
    [self.leftButton setTitle:@"LEFT: Disabled" forState:UIControlStateNormal];
    [self.leftButton setTitle:@"LEFT: Enabled" forState:UIControlStateSelected];
    [self.rightButton setTitle:@"RIGHT: Disabled" forState:UIControlStateNormal];
    [self.rightButton setTitle:@"RIGHT: Enabled" forState:UIControlStateSelected];
    
    
    [@[self.topButton, self.leftButton, self.rightButton, self.bottomButton] makeObjectsPerformSelector:@selector(setBackgroundColor:)
                                                                                             withObject:[UIColor greenColor]];
    [self prettifyButtons];
    
    
    /*Configure reload View*/
    self.reloadView.supportedReloadDirections = kReloadDirection_topBottom | kReloadDirection_leftRight | kReloadDirection_bottomTop | kReloadDirection_rightLeft;
    self.reloadView.reloadDelegate = self;
    self.reloadView.reloadDatasource = self;
    self.reloadView.minOffsetLeftRight = 100.0f;
    self.reloadView.maxOffsetLeftRight = 100.0f;
    
    self.reloadView.rightSeparatorLine.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - ReloadView Delegate

- (void)reloadView:(PGTReloadView *)reloadView didTriggerForDirection:(eReloadDirection)reloadDirection reloadIcon:(UIView *)reloadIcon {
    if (reloadDirection == kReloadDirection_topBottom) {
        _animateTop = NO;
        [_reloadView resetOffset];
    }
    else if (reloadDirection == kReloadDirection_bottomTop) {
        [(UIActivityIndicatorView *)reloadIcon startAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            reloadIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.reloadView resetOffset];
            });
        });
    }
    else if (reloadDirection == kReloadDirection_leftRight) {
        [UIView animateWithDuration:0.3f animations:^{
            reloadIcon.transform = CGAffineTransformScale(reloadIcon.transform, 2.0f, 2.0f);
            CGRect frame = reloadIcon.frame;
            frame.origin.x = - 200;
            reloadIcon.frame = frame;
            reloadIcon.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _animateLeft = NO;
            [self.reloadView resetOffset];
        }];
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.reloadView resetOffset];
        });
    }
}


- (void)reloadView:(PGTReloadView *)reloadView didScrollInDirection:(eReloadDirection)reloadDirection reloadIcon:(UIView *)reloadIcon offset:(CGFloat)offset {
    if (reloadDirection == kReloadDirection_topBottom) {
        if (offset <= self.reloadView.minOffsetTopBottom && _animateTop) {
            float deltaOffset = offset - _topOffset;
            CGFloat percent = deltaOffset * 100 / reloadView.minOffsetTopBottom;
            [reloadIcon setTransform:CGAffineTransformRotate(reloadIcon.transform, degreesToRadians(percent / 100 * 180))];
            _topOffset = offset;
        }
    }
    else if (reloadDirection == kReloadDirection_leftRight) {
        if (_animateLeft) {
            CGFloat size = offset / 100 * 50;
            CGRect frame = reloadIcon.frame;
            frame.size.width = size;
            frame.size.height = size;
            frame.origin.x = (-1) * frame.size.width - 20;
            reloadIcon.frame = frame;
        }
    }
}

- (void)reloadView:(PGTReloadView *)reloadView didResetOffsetForDirection:(eReloadDirection)reloadDirection {

}

#pragma mark - ReloadView Datasource

- (BOOL)shouldShowCustomReloadIconForDirection:(eReloadDirection)reloadDirection {
    if (reloadDirection == kReloadDirection_topBottom) {
        _topOffset = 0.0f;
        _animateTop = YES;
        return YES;
    }
    else if (reloadDirection == kReloadDirection_bottomTop) {
        return NO;
    }
    else if (reloadDirection == kReloadDirection_leftRight) {
        _animateLeft = YES;
        return YES;
    }
    return NO;
}


- (UIView *)reloadIconForDirection:(eReloadDirection)reloadDirection {
    if (reloadDirection == kReloadDirection_topBottom) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock"]];
        imageView.frame = CGRectMake(0, 0, 30, 30);
        [imageView setTransform:CGAffineTransformRotate(imageView.transform, degreesToRadians(180))];
        return imageView;
    }
    else if (reloadDirection == kReloadDirection_bottomTop) {
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.hidden = NO;
        return view;
    }
    else if (reloadDirection == kReloadDirection_leftRight) {
        UIImage *image = [UIImage imageNamed:@"social"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, 1, 1);
        return imageView;
    }
    return nil;
}




- (IBAction)didPressConfigurationButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        sender.backgroundColor = [UIColor greenColor];
    }
    else {
        sender.backgroundColor = [UIColor clearColor];
    }
    self.reloadView.supportedReloadDirections = [self supportedReloadDirections];
}


- (int)supportedReloadDirections {
    int supportedDirections = 0;
    supportedDirections = self.topButton.isSelected ? supportedDirections | kReloadDirection_topBottom : supportedDirections;
    supportedDirections = self.leftButton.isSelected ? supportedDirections | kReloadDirection_leftRight : supportedDirections;
    supportedDirections = self.rightButton.isSelected ? supportedDirections | kReloadDirection_rightLeft : supportedDirections;
    supportedDirections = self.bottomButton.isSelected ? supportedDirections | kReloadDirection_bottomTop : supportedDirections;
    return supportedDirections;
}


- (void)prettifyButtons {
    for (UIButton *button in @[self.topButton, self.leftButton, self.rightButton, self.bottomButton]) {
        button.layer.borderColor = [UIColor blackColor].CGColor;
        button.layer.borderWidth = 0.5f;
    }
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
