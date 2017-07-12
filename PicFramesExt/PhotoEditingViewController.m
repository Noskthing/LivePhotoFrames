//
//  PhotoEditingViewController.m
//  PicFramesExt
//
//  Created by ml on 2017/7/10.
//  Copyright © 2017年 Noskthing. All rights reserved.
//

#import "PhotoEditingViewController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "ContentEditManager.h"
#import "GCDThrottle.h"
#import "SliderView.h"

@interface PhotoEditingViewController () <PHContentEditingController, ContentEditManagerDelegate, SliderViewDelegate>
@property (strong) PHContentEditingInput *input;
@property (strong, nonatomic)ContentEditManager *contentEditManager;
@property (strong, nonatomic)AVAsset * ava;
@property (strong, nonatomic)AVAssetImageGenerator *assetImageGenerator;
@property (weak, nonatomic) IBOutlet UIImageView *backgroudImageView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet PHLivePhotoView *livePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet SliderView *sliderView;

@end

@implementation PhotoEditingViewController

- (ContentEditManager *)contentEditManager
{
    if (!_contentEditManager)
    {
        _contentEditManager = [[ContentEditManager alloc] init];
        _contentEditManager.delegate = self;
    }
    return _contentEditManager;
}

#pragma mark - Get frame from video
- (UIImage *)thumbnailImageForVideo:(AVAssetImageGenerator *)assetImageGenerator atTime:(NSTimeInterval)time
{
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 600)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef]:nil;
    return thumbnailImage;
}

#pragma mark - Buttons Events
- (IBAction)minusButtonTouch:(UIButton *)sender
{
    [self.sliderView scrollToLeft];
}

- (IBAction)addButtonTouched:(UIButton *)sender
{
    [self.sliderView scrollToRight];
}

#pragma mark - SliderView deledate
- (void)sliderView:(SliderView * _Nullable)sliderView updateScale:(CGFloat)scale isTouchesEnded:(BOOL)isEnd
{
    self.timeLabel.text = [NSString stringWithFormat:@"%.2f/%.2f", (scale * CMTimeGetSeconds(_ava.duration)),CMTimeGetSeconds(_ava.duration)];
    if (isEnd)
    {
        dispatch_throttle(0.5, ^{
            UIImage * im = [self thumbnailImageForVideo:_assetImageGenerator atTime:scale * _ava.duration.value];
            self.previewImageView.image = im;
        });
    }
}

#pragma mark - ContentEditManagerDelegate
- (void)contentEditManager:(ContentEditManager *)manager updateLivePhoto:(PHLivePhoto *)livePhoto
{
    if (livePhoto)
    {
        NSString * fileName = @"tempAssetVideo.mov";
        NSString * PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        NSArray * resources = [PHAssetResource assetResourcesForLivePhoto:livePhoto];
        [[NSFileManager defaultManager] removeItemAtPath: PATH_MOVIE_FILE error: nil];
        if (resources.count > 0)
        {
            
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resources[1] toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]options:nil completionHandler:^(NSError * _Nullable error) {
                if (error)
                {
                    NSLog(@"error is %@", error);
                }
                else
                {
                    _ava = [AVAsset assetWithURL:[NSURL fileURLWithPath: PATH_MOVIE_FILE]];
                    
                    _assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:_ava];
                    _assetImageGenerator.appliesPreferredTrackTransform = YES;
                    _assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeProductionAperture;
                    
                    NSMutableArray * images = [NSMutableArray array];
                    for (int i = 1; i <= 10; i++)
                    {
                        CGFloat scale = i/10.;
                        UIImage * tempImage = [self thumbnailImageForVideo:_assetImageGenerator atTime:scale * _ava.duration.value];
                        [images addObject:tempImage];
                    }
                    [_sliderView drawBackgroudImage:[images copy]];
                    _sliderView.delegate = self;
                }
                [[NSFileManager defaultManager] removeItemAtPath: PATH_MOVIE_FILE error: nil];
            }];

        }
        
        _livePhotoView.livePhoto = livePhoto;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)contentEditManager:(ContentEditManager *)manager duration:(Float64)duration currentTime:(Float64)currentTime
{
    self.timeLabel.text = [NSString stringWithFormat:@"%.2f/%.2f", currentTime, duration];
    self.sliderView.scale = currentTime/duration;
    self.sliderView.unitOfScale = 0.01/duration;
}

#pragma mark - PHContentEditingController
- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
    // Inspect the adjustmentData to determine whether your extension can work with past edits.
    // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
    return YES;
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
    // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
    // If you returned YES from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
    // If you returned NO, the contentEditingInput has past edits "baked in".
    
    self.input = contentEditingInput;

    self.previewImageView.image = placeholderImage;
    self.backgroudImageView.image = placeholderImage;
    [self.contentEditManager startContentEditingWithInput:contentEditingInput];
}

- (void)finishContentEditingWithCompletionHandler:(void (^)(PHContentEditingOutput *))completionHandler {
    // Update UI to reflect that editing has finished and output is being rendered.
    
    // Render and provide output on a background queue.
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        // Create editing output from the editing input.
        PHContentEditingOutput *output = [[PHContentEditingOutput alloc] initWithContentEditingInput:self.input];
        
        //系统的方法会覆盖原图 所以不用注释提供的方法直接写入相册
        
        // Provide new adjustments and render output to given location.
        // output.adjustmentData = <#new adjustment data#>;
        // NSData *renderedJPEGData = <#output JPEG#>;
        // [renderedJPEGData writeToURL:output.renderedContentURL atomically:YES];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:self.previewImageView.image];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success)
                return ;
        }];
    
        // Call completion handler to commit edit to Photos.
        completionHandler(output);
        
        // Clean up temporary files, etc.
    });
}

- (BOOL)shouldShowCancelConfirmation {
    // Returns whether a confirmation to discard changes should be shown to the user on cancel.
    // (Typically, you should return YES if there are any unsaved changes.)
    return NO;
}

- (void)cancelContentEditing {
    // Clean up temporary files, etc.
    // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
}

@end
