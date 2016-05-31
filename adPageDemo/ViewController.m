//
//  ViewController.m
//  adPageDemo
//
//  Created by zwm on 15/5/18.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "ViewController.h"
#import "WMAdPageView.h"
#import "WMAdPageFView.h"

#define kScreen_Width [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
{
    CGFloat _HeadHeight;
}
@property (weak, nonatomic) IBOutlet WMAdPageView *adPageView;
@property (weak, nonatomic) IBOutlet WMAdPageFView *adPageFView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headHLayout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headTopLayout;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [_adPageView setAdsWithImages:@[@"m1", @"m2", @"m3", @"m4", @"m5"]
                             block:^(NSInteger clickIndex){
                                 NSLog(@"%ld", (long)clickIndex);
                             }];
    //[_adPageView setBAutoRoll:YES];
    
    [_adPageFView setAdsWithImages:@[@"m1", @"m2", @"m3", @"m4", @"m5"]
                              block:^(NSInteger clickIndex){
                                  NSLog(@"%ld", (long)clickIndex);
                              }];
    [_adPageFView setBAutoRoll:YES];
    
    _HeadHeight = 112 * kScreen_Width / 320;
    _headHLayout.constant = _HeadHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        _headHLayout.constant = _HeadHeight - scrollView.contentOffset.y;
        if (_headTopLayout.constant != 0) {
            _headTopLayout.constant = 0;
        }
    } else {
        _headTopLayout.constant = -scrollView.contentOffset.y;
    }
}

@end
