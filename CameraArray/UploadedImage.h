//
//  UploadedImage.h
//  CameraArray
//
//  Created by Teemu Lehtinen on 21.4.2013.
//  Copyright (c) 2013 Teemu Lehtinen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadedImage : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UIImageView *view;

+ (UploadedImage *)uploadedImageWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image;

@end
