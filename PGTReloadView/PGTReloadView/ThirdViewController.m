//
//  ThirdViewController.m
//  PGTReloadView
//
//  Created by Reinhard on 04/01/16.
//  Copyright © 2016 PGIT. All rights reserved.
//

#import "ThirdViewController.h"
#import "PGTReloadView.h"


@interface ThirdViewController () <PGTReloadViewDelegate>
@property (strong, nonatomic) PGTReloadView *reloadView;
@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _reloadView = [[PGTReloadView alloc] init];
    _reloadView.supportedReloadDirections = kReloadDirection_topBottom | kReloadDirection_leftRight | kReloadDirection_bottomTop | kReloadDirection_rightLeft;
    _reloadView.reloadDelegate = self;
    _reloadView.backgroundColor = [UIColor greenColor];
    // Do any additional setup after loading the view.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.view addSubview:_reloadView];
    [self.reloadView setFrame:CGRectMake(20, 20, 200, 200)];
//    self.reloadView.frame = CGRectMake(20, 20, 200, 200);
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
