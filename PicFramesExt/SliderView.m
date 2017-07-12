//
//  SliderView.m
//  PicFrames
//
//  Created by ml on 2017/7/12.
//  Copyright © 2017年 Noskthing. All rights reserved.
//

#import "SliderView.h"

@interface SliderView ()

@property (nonatomic, strong)NSArray *images;
@property (nonatomic, strong)UIView *pointView;
@end

@implementation SliderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (!_pointView)
    {
        _scale = 0;
        _unitOfScale = 0.01;
        
        _pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.frame.size.height + 8)];
        _pointView.backgroundColor = [UIColor redColor];
        _pointView.layer.position = CGPointMake(0, self.frame.size.height/2);
        [self addSubview:_pointView];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        _scale = 0;
        _unitOfScale = 0.01;
        
        _pointView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, frame.size.height + 4)];
        _pointView.backgroundColor = [UIColor redColor];
        _pointView.layer.position = CGPointMake(0, frame.size.height/2);
        [self addSubview:_pointView];
    }
    return self;
}

// Mark: Paramters check
- (void)setScale:(CGFloat)scale
{
    _scale = [self getInvaildScale:scale];
    _pointView.layer.position = CGPointMake(_scale * self.frame.size.width, self.frame.size.height/2);
}

- (CGFloat)getInvaildScale:(CGFloat)scale
{
    CGFloat x;
    if (scale < 0)
    {
        x = 0;
    }
    else if (scale > self.frame.size.width)
    {
        x = self.frame.size.width;
    }
    else
    {
        x = scale;
    }
    return x;
}

// Scale change
- (void)scrollToLeft
{
    _scale -= _unitOfScale;
    if ([self.delegate respondsToSelector:@selector(sliderView:updateScale:isTouchesEnded:)])
    {
        [self.delegate sliderView:self updateScale:_scale isTouchesEnded:YES];
    }
}

- (void)scrollToRight
{
    _scale += _unitOfScale;
    if ([self.delegate respondsToSelector:@selector(sliderView:updateScale:isTouchesEnded:)])
    {
        [self.delegate sliderView:self updateScale:_scale isTouchesEnded:YES];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (_images && _images.count > 0)
    {
        CGFloat width = self.frame.size.width/_images.count;
        CGFloat height = self.frame.size.height;
        
        for (int i = 0; i < _images.count; i++)
        {
            UIImage * image = _images[i];
            [image drawInRect:CGRectMake(i * width, 0, width, height)];
        }
    }
}

- (void)drawBackgroudImage:(NSArray<UIImage *> *)images
{
    _images = images;
    [self setNeedsDisplay];
}

// Touch events
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _scale = [self getInvaildScale:point.x]/self.frame.size.width;
    _pointView.layer.position = CGPointMake([self getInvaildScale:point.x], self.frame.size.height/2);
    if ([self.delegate respondsToSelector:@selector(sliderView:updateScale:isTouchesEnded:)])
    {
        [self.delegate sliderView:self updateScale:_scale isTouchesEnded:NO];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _scale = [self getInvaildScale:point.x]/self.frame.size.width;
    _pointView.layer.position = CGPointMake([self getInvaildScale:point.x], self.frame.size.height/2);
    if ([self.delegate respondsToSelector:@selector(sliderView:updateScale:isTouchesEnded:)])
    {
        [self.delegate sliderView:self updateScale:_scale isTouchesEnded:YES];
    }
}
@end
