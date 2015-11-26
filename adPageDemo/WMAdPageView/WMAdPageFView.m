//
//  WMAdPageFView.m
//
//  Created by zwm on 15/5/25.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WMAdPageFView.h"
#import "TAPageControl.h"
#import "WMDotView.h"

@interface WMAdPageFView() <UIScrollViewDelegate, TAPageControlDelegate>
@property (nonatomic, copy) NSArray *arrImage;
@property (nonatomic, assign) NSInteger indexShow;
@property (nonatomic, strong) UIScrollView *scView;
@property (nonatomic, strong) NSMutableArray *scImgView;
@property (nonatomic, assign) WMAdPageFCallback myBlock;
@property (nonatomic, strong) TAPageControl *pageControl;
@property (nonatomic, strong) NSTimer *autoRollTimer;
@end

@implementation WMAdPageFView
@synthesize delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    self.scView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_scView) {
        self.scView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        [_scView setFrame:self.bounds];

        for (int i=0; i<_scImgView.count; i++) {
            UIImageView *img = _scImgView[i];
            [img setFrame:CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height)];
        }
        
        if (_arrImage.count <= 1) {
            _scView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
            [_scView scrollRectToVisible:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) animated:NO];
        } else {
            _scView.contentSize = CGSizeMake(self.frame.size.width * (_arrImage.count + 2), self.frame.size.height);
            [_scView scrollRectToVisible:CGRectMake(self.frame.size.width * (_indexShow + 1), 0, self.frame.size.width, self.frame.size.height) animated:NO];
        }

        [_pageControl setFrame:CGRectMake(0, self.frame.size.height - kPageControlH, self.frame.size.width, kPageControlH)];
        [_pageControl resetDotViews];
    }
}

- (void)initUI
{
    if (!_scView) {
        _scView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scView.delegate = self;
        _scView.pagingEnabled = YES;
        _scView.bounces = NO;
        _scView.showsHorizontalScrollIndicator = NO;
        _scView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scView];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAds)];
        [_scView addGestureRecognizer:tap];
    }
    
    if (!_scImgView) {
        _scImgView = [NSMutableArray arrayWithCapacity:_arrImage.count + 2];
    }
    for (UIImageView *img in _scImgView) {
        [img removeFromSuperview];
    }
    [_scImgView removeAllObjects];

    if (_bWebImage) {
        if (delegate && [delegate respondsToSelector:@selector(setWebImage:imgUrl:)]) {
            for (int i=0; i<_arrImage.count && _arrImage.count > 1; i++) {
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * (i + 1), 0, self.frame.size.width, self.frame.size.height)];
                [_scImgView addObject:img];
                [_scView addSubview:img];
                [delegate setWebImage:img imgUrl:_arrImage[i]];
            }
            if (_arrImage.count > 1) {
                UIImageView *img0 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                [_scImgView insertObject:img0 atIndex:0];
                [_scView addSubview:img0];
                [delegate setWebImage:img0 imgUrl:_arrImage[(_arrImage.count - 1)]];
                UIImageView *img1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * (_arrImage.count + 1), 0, self.frame.size.width, self.frame.size.height)];
                [_scImgView addObject:img1];
                [_scView addSubview:img1];
                [delegate setWebImage:img1 imgUrl:_arrImage[0]];
            } else if (_arrImage.count == 1) {
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                [_scImgView addObject:img];
                [_scView addSubview:img];
                [delegate setWebImage:img imgUrl:_arrImage[0]];
           }
        } else {
            for (int i=0; i<_arrImage.count && _arrImage.count > 1; i++) {
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * (i + 1), 0, self.frame.size.width, self.frame.size.height)];
                [_scImgView addObject:img];
                [_scView addSubview:img];
                img.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_arrImage[i]]]];
            }
            if (_arrImage.count > 1) {
                UIImageView *img0 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                [_scImgView insertObject:img0 atIndex:0];
                [_scView addSubview:img0];
                img0.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_arrImage[(_arrImage.count - 1)]]]];
                UIImageView *img1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * (_arrImage.count + 1), 0, self.frame.size.width, self.frame.size.height)];
                [_scImgView addObject:img1];
                [_scView addSubview:img1];
                img1.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_arrImage[0]]]];
            } else if (_arrImage.count == 1) {
                UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                [_scImgView addObject:img];
                [_scView addSubview:img];
                img.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_arrImage[0]]]];
            }
        }
    } else {
        for (int i=0; i<_arrImage.count && _arrImage.count > 1; i++) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * (i + 1), 0, self.frame.size.width, self.frame.size.height)];
            [_scImgView addObject:img];
            [_scView addSubview:img];
            img.image = [UIImage imageNamed:_arrImage[i]];
        }
        if (_arrImage.count > 1) {
            UIImageView *img0 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [_scImgView insertObject:img0 atIndex:0];
            [_scView addSubview:img0];
            img0.image = [UIImage imageNamed:_arrImage[(_arrImage.count - 1)]];
            UIImageView *img1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width * (_arrImage.count + 1), 0, self.frame.size.width, self.frame.size.height)];
            [_scImgView addObject:img1];
            [_scView addSubview:img1];
            img1.image = [UIImage imageNamed:_arrImage[0]];
        } else if (_arrImage.count == 1) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [_scImgView addObject:img];
            [_scView addSubview:img];
            img.image = [UIImage imageNamed:_arrImage[0]];
        }
    }
    
    if (!_pageControl) {
        _pageControl = [[TAPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kPageControlH, self.frame.size.width, kPageControlH)];
        //_pageControl.dotViewClass = [WMDotView class];
        _pageControl.delegate = self;
        [self addSubview:_pageControl];
    }
}

- (void)TAPageControl:(TAPageControl *)pageControl didSelectPageAtIndex:(NSInteger)index
{
    if ([_autoRollTimer isValid]) {
        [_autoRollTimer invalidate];
        _autoRollTimer = nil;
    }
    if (_bAutoRoll) {
        _autoRollTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoRollTime target:self selector:@selector(scrollTimer) userInfo:nil repeats:YES];
    }
    [_scView scrollRectToVisible:CGRectMake(self.frame.size.width * (index + 1), 0, CGRectGetWidth(_scView.frame), CGRectGetHeight(_scView.frame)) animated:YES];
}

- (void)dealloc
{
    if ([_autoRollTimer isValid]) {
        [_autoRollTimer invalidate];
        _autoRollTimer = nil;
    }
}

- (void)setBAutoRoll:(BOOL)bAutoRoll
{
    _bAutoRoll = bAutoRoll;
    if ([_autoRollTimer isValid]) {
        [_autoRollTimer invalidate];
        _autoRollTimer = nil;
    }
    if (_bAutoRoll) {
        _autoRollTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoRollTime target:self selector:@selector(scrollTimer) userInfo:nil repeats:YES];
    }
}

- (void)setAdsWithImages:(NSArray *)imageArray block:(WMAdPageFCallback)block
{
    if (!imageArray || imageArray.count<=0) {
        return;
    }
    _arrImage = imageArray;
    _myBlock = block;
    
    [self initUI];
    if (_arrImage.count <= 1) {
        _scView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    } else {
        _scView.contentSize = CGSizeMake(self.frame.size.width * (_arrImage.count + 2), self.frame.size.height);
    }
    _pageControl.numberOfPages = imageArray.count;
    
    [self reloadImages];
}

- (void)tapAds
{
    if (_myBlock != NULL) {
        _myBlock(_indexShow);
    }
}

- (void)reloadImages
{
    if (_indexShow >= (int)_arrImage.count) {
        _indexShow = 0;
    }
    if (_indexShow < 0) {
        _indexShow = (int)_arrImage.count - 1;
    }
    _pageControl.currentPage = _indexShow;
    [_scView scrollRectToVisible:CGRectMake(self.frame.size.width * (_indexShow + 1), 0, self.frame.size.width, self.frame.size.height) animated:NO];
}

// 定时滚动
- (void)scrollTimer
{
    if (_arrImage.count > 1) {
        [_scView scrollRectToVisible:CGRectMake(self.frame.size.width * (_indexShow + 2), 0, self.frame.size.width, self.frame.size.height) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _indexShow = scrollView.contentOffset.x / self.frame.size.width - 1;
    [self reloadImages];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_autoRollTimer isValid]) {
        [_autoRollTimer invalidate];
        _autoRollTimer = nil;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_bAutoRoll) {
        _autoRollTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoRollTime target:self selector:@selector(scrollTimer) userInfo:nil repeats:YES];
    }
    _indexShow = scrollView.contentOffset.x / self.frame.size.width - 1;
    [self reloadImages];
}

@end
