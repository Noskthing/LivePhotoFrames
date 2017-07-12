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
        
//        NSLog(@"duration value is %lld -- scale is %d",self.livePhotoContext.duration.value, self.livePhotoContext.duration.timescale
//              );
//        NSLog(@"phototime value is %lld -- scale is %d",self.livePhotoContext.photoTime.value, self.livePhotoContext.photoTime.timescale
//              );
        [self.delegate contentEditManager:self duration:CMTimeGetSeconds(self.livePhotoContext.duration) currentTime:CMTimeGetSeconds(self.livePhotoContext.photoTime)];
        [self.delegate contentEditManager:self updateLivePhoto:_input.livePhoto];
    }
}



- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput
{
    _input = contentEditingInput;
    [self updateLivePhotoIfNeeded];
}
@end
