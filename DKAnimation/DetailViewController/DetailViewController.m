//
//  DetailViewController.m
//  DKAnimation
//
//  Created by daisuke on 2017/3/20.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+DKAmimation.h"
#import "DKAnimation.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@end

@implementation DetailViewController

#pragma mark - private instance method

#pragma mark * init value

- (void)setupInitValues {
    self.headerImageView.image = self.headerImage;
    self.headerImageView.hidden = YES;
    self.view.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dkAnimationComplete) name:@"dkAnimationComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dkAnimationPop) name:@"dkAnimationPop" object:nil];
}

- (void)dkAnimationComplete {
    self.headerImageView.hidden = NO;
}

- (void)dkAnimationPop {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)setupNavigationBar {
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}

- (void)back {
    self.headerImageView.hidden = YES;
    
    UIImageView *selectedImageView = [DKAnimation shared].backAnimationInfo[[NSValue valueWithNonretainedObject:self]];
    [selectedImageView dk_backAnimation:self];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValues];
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
