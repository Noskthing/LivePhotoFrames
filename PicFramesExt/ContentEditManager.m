//
//  ContentEditManager.m
//  PicFrames
//
//  Created by ml on 2017/7/10.
//  Copyright © 2017年 Noskthing. All rights reserved.
//

#import "ContentEditManager.h"

@interface ContentEditManager ()

@property (strong, nonatomic)PHContentEditingInput *input;
@property (strong, nonatomic)PHLivePhotoEditingContext *livePhotoContext;
@end

@implementation ContentEditManager

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (PHLivePhotoEditingContext *)livePhotoContext
{
    if (!_livePhotoContext)
    {
        _livePhotoContext = [[PHLivePhotoEditingContext alloc] initWithLivePhotoEditingInput:_input];
    }
    return _livePhotoContext;
}

- (void)updateLivePhotoIfNeeded
{
    if (_input.livePhoto != nil)
    {
        self.livePhotoContext.frameProcessor = ^CIImage * _Nullable(id<PHLivePhotoFrame>  _Nonnull frame, NSError *__autoreleasing  _Nullable * _Nonnull error) {
            return frame.image;
        };
        
        [self.delegate contentEditManager:self updateTime:[NSString stringWithFormat:@"%.2f/%.2f", CMTimeGetSeconds(self.livePhotoContext.photoTime), CMTimeGetSeconds(self.livePhotoContext.duration)] scaleValue:CMTimeGetSeconds(self.livePhotoContext.photoTime)/CMTimeGetSeconds(self.livePhotoContext.duration)];
        [self.delegate contentEditManager:self updateLivePhoto:_input.livePhoto];
    }
    
    
}



- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput
{
    _input = contentEditingInput;
    [self updateLivePhotoIfNeeded];
}
@end
