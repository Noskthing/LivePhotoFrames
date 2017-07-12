//
//  SliderView.h
//  PicFrames
//
//  Created by ml on 2017/7/12.
//  Copyright © 2017年 Noskthing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SliderView;
@protocol SliderViewDelegate <NSObject>

- (void)sliderView:(SliderView * _Nullable)sliderView updateScale:(CGFloat)scale isTouchesEnded:(BOOL)isEnd;

@end

@interface SliderView : UIView

@property (assign, nonatomic)CGFloat scale;

@property (assign, nonatomic)CGFloat unitOfScale;

@property (weak, nonatomic, nullable)id<SliderViewDelegate> delegate;

- (void)drawBackgroudImage:(nonnull NSArray <UIImage *>*)images;

- (void)scrollToLeft;
- (void)scrollToRight;
@end
