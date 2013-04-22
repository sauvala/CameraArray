//
//  UploadConnection.h
//  CameraArray
//
//  Created by Teemu Lehtinen on 15.4.2013.
//  Copyright (c) 2013 Teemu Lehtinen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

@class MultipartFormDataParser;

@interface UploadConnection : HTTPConnection

@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) MultipartFormDataParser *parser;

@end
