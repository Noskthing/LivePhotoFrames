//
//  ContentEditManager.h
//  PicFrames
//
//  Created by ml on 2017/7/10.
//  Copyright © 2017年 Noskthing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@class ContentEditManager;
@protocol ContentEditManagerDelegate <NSObject>

- (void)contentEditManager:(ContentEditManager *)manager updateLivePhoto:(PHLivePhoto *)livePhoto;

- (void)contentEditManager:(ContentEditManager *)manager updateTime:(NSString *)time scaleValue:(CGFloat)scale;
@end

@interface ContentEditManager : NSObject

@property (strong, nonatomic)id<ContentEditManagerDelegate> delegate;

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput;

@end
