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

@interface PhotoEditingViewController () <PHContentEditingController, ContentEditManagerDelegate>
@property (strong) PHContentEditingInput *input;
@property (strong, nonatomic)ContentEditManager *contentEditManager;
@property (strong, nonatomic)AVAsset * ava;
@property (weak, nonatomic) IBOutlet UIImageView *backgroudImageView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet PHLivePhotoView *livePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)progressValueChange:(UISlider *)sender
{
    UIImage * im = [self thumbnailImageForVideo:_ava atTime:sender.value * _ava.duration.value];
    self.previewImageView.image = im;
    
    self.timeLabel.text = [NSString stringWithFormat:@"%.2f/%.2f", (sender.value * CMTimeGetSeconds(_ava.duration)),CMTimeGetSeconds(_ava.duration)];
}

- (UIImage *)thumbnailImageForVideo:(AVAsset *)asset atTime:(NSTimeInterval)time {
    NSLog(@"time is %f",time);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeProductionAperture;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 600)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : nil;
    return thumbnailImage;
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
                if (error) {
                    NSLog(@"error is %@", error);
                } else {
                    NSData * data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath: PATH_MOVIE_FILE]];
                    NSLog(@"DATA LENGHT %lu", (unsigned long)data.length);
                    _ava = [AVAsset assetWithURL:[NSURL fileURLWithPath: PATH_MOVIE_FILE]];
                    NSLog(@"ava time is %d",_ava.duration.timescale);
                    
                    [self.progressSlider addTarget:self action:@selector(progressValueChange:) forControlEvents:UIControlEventTouchUpInside];
                }
                [[NSFileManager defaultManager] removeItemAtPath: PATH_MOVIE_FILE error: nil];
            }];

        }
        
        _livePhotoView.livePhoto = livePhoto;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)contentEditManager:(ContentEditManager *)manager updateTime:(NSString *)time scaleValue:(CGFloat)scale
{
    self.timeLabel.text = time;
    self.progressSlider.value = scale;
}

#pragma mark - PHContentEditingController

- (BOOL)canHandleAdjustmentData:(PHAdjustmentData *)adjustmentData {
    // Inspect the adjustmentData to determine whether your extension can work with past edits.
    // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
    return [adjustmentData.formatIdentifier  isEqual:[[NSBundle bundleForClass:[ContentEditManager class]] bundleIdentifier]] && [adjustmentData.formatVersion  isEqual: @"1.0"];
}

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput placeholderImage:(UIImage *)placeholderImage {
    // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
    // If you returned YES from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
    // If you returned NO, the contentEditingInput has past edits "baked in".
    
    self.input = contentEditingInput;
    NSLog(@"------");
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
        
        // Provide new adjustments and render output to given location.
        // output.adjustmentData = <#new adjustment data#>;
        // NSData *renderedJPEGData = <#output JPEG#>;
        // [renderedJPEGData writeToURL:output.renderedContentURL atomically:YES];
        
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
