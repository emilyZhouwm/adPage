
![](./adPage.gif)

    [_adPageFView setAdsWithImages:@[@"m1", @"m2", @"m3", @"m4", @"m5"]
                              block:^(NSInteger clickIndex){
                                  NSLog(@"%ld", (long)clickIndex);
                              }];
    [_adPageFView setBAutoRoll:YES];