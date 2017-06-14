//
//  TableCell.m
//  DKAnimation
//
//  Created by daisuke on 2017/3/20.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "TableCell.h"
#import "UIImageView+DKAmimation.h"
#import "DetailViewController.h"

@interface TableCell () <UIImageViewDKAmimationDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@end

@implementation TableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self = arrayOfViews[0];
        [self.imageView1 addGestureWithClass:self];
        [self.imageView2 addGestureWithClass:self];
    }
    return self;
}

#pragma mark - UIImageViewDKAmimationDelegate

- (UIViewController *)dk_pushToViewController {
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.headerImage = [UIImage imageNamed:@"images"];
    return detailViewController;
}

- (UIView *)dk_selectedArea {
    return self;
}

- (CGRect)dk_selectedImageViewMovewToFrame {
    CGFloat width = CGRectGetWidth(self.imageView2.frame);
    CGFloat height = CGRectGetHeight(self.imageView2.frame);
    CGFloat scale = (CGRectGetWidth([UIScreen mainScreen].bounds) / width);
    return CGRectMake(0, 64,  width * scale, height * scale);
}

- (CGFloat)dk_animateDuration {
    return 0.4f;
}

- (NSArray *)dk_centerViews {
    return @[self.imageView1, self.imageView2];
}

@end
