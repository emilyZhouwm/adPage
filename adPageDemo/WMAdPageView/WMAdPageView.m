//
//  WMAdPageView.m
//
//  Created by zwm on 15/5/25.
//  Copyright (c) 2015年 zwm. All rights reserved.
//

#import "WMAdPageView.h"
#import "TAPageControl.h"
#import "WMDotView.h"

static Class _cellClass = nil;

@interface WMAdPageView() <UIScrollViewDelegate>
@property (nonatomic, copy) NSArray *arrImage;
@property (nonatomic, assign) NSInteger indexShow;
@property (nonatomic, assign) NSInteger nextShow;
@property (nonatomic, strong) UIScrollView *scView;
@property (nonatomic, strong) UIImageView *imgPrev;
@property (nonatomic, strong) UIImageView *imgCurrent;
@property (nonatomic, strong) UIImageView *imgNext;
@property (nonatomic, assign) WMAdPageCallback myBlock;
@property (nonatomic, strong) TAPageControl *pageControl;
@property (nonatomic, strong) NSTimer *autoRollTimer;
@end

@implementation WMAdPageView

+ (void)setCellClass:(Class)cellClass
{
    _cellClass = cellClass;
}

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_scView) {
        [_scView setFrame:self.bounds];

        [_imgPrev setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [_imgCurrent setFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        [_imgNext setFrame:CGRectMake(2 * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        
        if (_arrImage.count <= 1) {
            _scView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
            [_scView scrollRectToVisible:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) animated:NO];
        } else {
            _scView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
            [_scView scrollRectToVisible:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:NO];
        }
        
        CGRect frame;
        CGSize size = [_cellClass dotSize];
        switch (_dotPosition) {
            case WMAdPageDotLeft: {
                CGFloat width = _dotSpacing + (size.width + _dotSpacing) * _arrImage.count;
                frame = CGRectMake(0, self.frame.size.height - kPageControlH, width, kPageControlH);
                break;
            }
            case WMAdPageDotRight: {
                CGFloat width = _dotSpacing + (size.width + _dotSpacing) * _arrImage.count;
                frame = CGRectMake(self.frame.size.width - width, self.frame.size.height - kPageControlH, width, kPageControlH);
                break;
            }
            default: {
                frame = CGRectMake(0, self.frame.size.height - kPageControlH, self.frame.size.width, kPageControlH);
                break;
            }
        }
        [_pageControl setFrame:frame];
        [_pageControl resetDotViews];
    }
}

- (void)initUI
{
    _scView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scView.delegate = self;
    _scView.pagingEnabled = YES;
    _scView.bounces = NO;
    _scView.showsHorizontalScrollIndicator = NO;
    _scView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAds)];
    [_scView addGestureRecognizer:tap];
    
    _imgPrev = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _imgCurrent = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    _imgNext = [[UIImageView alloc] initWithFrame:CGRectMake(2 * self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    
    [_scView addSubview:_imgPrev];
    [_scView addSubview:_imgCurrent];
    [_scView addSubview:_imgNext];
    
    if (!_cellClass) {
        _cellClass = [WMDotView class];
    }
    CGRect frame;
    CGSize size = [_cellClass dotSize];
    _pageControl = [[TAPageControl alloc] initWithFrame:frame];
    _dotSpacing = _dotSpacing > 0 ? _dotSpacing : _pageControl.spacingBetweenDots;
    _pageControl.spacingBetweenDots = _dotSpacing;
    
    switch (_dotPosition) {
        case WMAdPageDotLeft: {
            CGFloat width = _dotSpacing + (size.width + _dotSpacing) * _arrImage.count;
            frame = CGRectMake(0, self.frame.size.height - kPageControlH, width, kPageControlH);
            break;
        }
        case WMAdPageDotRight: {
            CGFloat width = _dotSpacing + (size.width + _dotSpacing) * _arrImage.count;
            frame = CGRectMake(self.frame.size.width - width, self.frame.size.height - kPageControlH, width, kPageControlH);
            break;
        }
        default: {
            frame = CGRectMake(0, self.frame.size.height - kPageControlH, self.frame.size.width, kPageControlH);
            break;
        }
    }
    [_pageControl setFrame:frame];
    _pageControl.dotViewClass = _cellClass;
    _pageControl.dotSize = size;
    [self addSubview:_pageControl];
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

- (void)setAdsWithImages:(NSArray *)imageArray block:(WMAdPageCallback)block
{
    if (!imageArray || imageArray.count<=0) {
        return;
    }
    _arrImage = imageArray;
    _myBlock = block;
    
    if (!_scView) {
        [self initUI];
    }
    
    if (_arrImage.count <= 1) {
        _scView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    } else {
        _scView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
    }
    _pageControl.numberOfPages = _arrImage.count;
    
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
    NSInteger prev = _indexShow - 1;
    if (prev < 0) {
        prev = (int)_arrImage.count - 1;
    }
    NSInteger next = _indexShow + 1;
    if (next > _arrImage.count - 1) {
        next = 0;
    }
    
    _pageControl.currentPage = _indexShow;
    NSString *prevImage = [_arrImage objectAtIndex:prev];
    NSString *curImage = [_arrImage objectAtIndex:_indexShow];
    NSString *nextImage = [_arrImage objectAtIndex:next];
    if (_bWebImage) {
        if (_delegate && [_delegate respondsToSelector:@selector(setWebImage:imgUrl:)]) {
            [_delegate setWebImage:_imgPrev imgUrl:prevImage];
            [_delegate setWebImage:_imgCurrent imgUrl:curImage];
            [_delegate setWebImage:_imgNext imgUrl:nextImage];
        } else {
            _imgPrev.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:prevImage]]];
            _imgCurrent.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:curImage]]];
            _imgNext.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:nextImage]]];
        }
    } else {
        _imgPrev.image = [UIImage imageNamed:prevImage];
        _imgCurrent.image = [UIImage imageNamed:curImage];
        _imgNext.image = [UIImage imageNamed:nextImage];
    }
    [_scView scrollRectToVisible:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:NO];
}

// 定时滚动
- (void)scrollTimer
{
    if (_arrImage.count > 1) {
        [_scView scrollRectToVisible:CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height) animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= self.frame.size.width * 2) {
        _indexShow++;
    } else if (scrollView.contentOffset.x < self.frame.size.width) {
        _indexShow--;
    }
    [self reloadImages];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= self.frame.size.width * 2) {
        _indexShow++;
    } else if (scrollView.contentOffset.x < self.frame.size.width) {
        _indexShow--;
    }
    [self reloadImages];
}

@end
