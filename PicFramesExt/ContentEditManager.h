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

- (void)contentEditManager:(ContentEditManager *)manager duration:(Float64)duration currentTime:(Float64)currentTime;
@end

/* 
 本意是将图片处理的操作丢到这个类来执行，比如滤镜 美化之类 还有不同类型的媒体文件的处理
 但是本项目主要是为了获取live photo的frame 而且只接收live photo类型的资源文件 没有其他的操作
 所以这个类显得很多余 -0-
 */
@interface ContentEditManager : NSObject

@property (strong, nonatomic)id<ContentEditManagerDelegate> delegate;

- (void)startContentEditingWithInput:(PHContentEditingInput *)contentEditingInput;

@end
