#广告轮播。使用简单。可自定义页面指示位置、样式和效果。

    [_adPageFView setAdsWithImages:@[@"m1", @"m2", @"m3", @"m4", @"m5"]
                              block:^(NSInteger clickIndex){
                                  NSLog(@"%ld", (long)clickIndex);
                              }];
    [_adPageFView setBAutoRoll:YES];
    
#####欢迎关注，反馈问题，维护修改。
######图片版权：考满分网
![](./adPage.gif)

![](./adPage.gif)

