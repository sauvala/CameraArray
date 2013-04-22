//
//  UploadServer.h
//  CameraArray
//
//  Created by Teemu Lehtinen on 15.4.2013.
//  Copyright (c) 2013 Teemu Lehtinen. All rights reserved.
//

#define SERVICE_TYPE @"_camera_array._tcp."

#import <Foundation/Foundation.h>
#import "HTTPServer.h"

@class UploadServer, UploadedImage;

@protocol UploadServerDelegate
- (void)server:(UploadServer *)server receivedImage:(UploadedImage *)image;
@end

@interface UploadServer : NSObject

@property (nonatomic) BOOL started;
@property (strong, nonatomic) NSString *serverName;
@property (strong, nonatomic) HTTPServer *server;
@property (strong) NSMutableArray *images;
@property (weak, nonatomic) id <UploadServerDelegate> delegate;

+ (UploadServer *)sharedServer;
- (id)init;
- (BOOL)start;
- (void)stopWithFinish:(BOOL)finish;
- (void)addImage:(UIImage *)image;

@end
