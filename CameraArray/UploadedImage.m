//
//  UploadedImage.m
//  CameraArray
//
//  Created by Teemu Lehtinen on 21.4.2013.
//  Copyright (c) 2013 Teemu Lehtinen. All rights reserved.
//

#import "UploadedImage.h"

@implementation UploadedImage

@synthesize image = _image, date = _date, view = _view;

+ (UploadedImage*)uploadedImageWithImage:(UIImage *)image
{
    return [[self alloc] initWithImage:image];
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self != nil)
    {
        self.image = image;
        self.date = [NSDate date];
    }
    return self;
}

@end
