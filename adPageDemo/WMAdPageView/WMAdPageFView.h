//
//  WMAdPageFView.h
//
//  Created by zwm on 15/5/25.
//  Copyright (c) 2015年 zwm. All rights reserved.
//
// 全部加载模式

#import <UIKit/UIKit.h>

#define kPageControlH 20
#define kAutoRollTime 3

@class WMAdPageFView;
typedef void (^WMAdPageFCallback)(NSInteger clickIndex);

@protocol WMAdPageFViewDelegate <NSObject>
- (void)setWebImage:(UIImageView *)imgView imgUrl:(NSString *)imgUrl;
@end

@interface WMAdPageFView : UIView
@property (nonatomic, assign) BOOL bWebImage; // 设置是否为网络图片
@property (nonatomic, assign) BOOL bAutoRoll; // 设置是否自动滚动
@property (nonatomic, assign) id<WMAdPageFViewDelegate> delegate;

- (void)setAdsWithImages:(NSArray*)imageArray block:(WMAdPageFCallback)block;

@end
