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
@property (weak, nonatomic) IBOutlet UIImageView *backgroudImageView;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet PHLivePhotoView *livePhotoView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

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

#pragma mark - ContentEditManagerDelegate
- (void)contentEditManager:(ContentEditManager *)manager updateLivePhoto:(PHLivePhoto *)livePhoto
{
    if (livePhoto)
    {
        _livePhotoView.livePhoto = livePhoto;
        _livePhotoView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)contentEditManager:(ContentEditManager *)manager updateTime:(NSString *)time
{
    self.timeLabel.text = time;
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
