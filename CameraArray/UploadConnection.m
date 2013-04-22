//
//  UploadConnection.m
//  CameraArray
//
//  Created by Teemu Lehtinen on 15.4.2013.
//  Copyright (c) 2013 Teemu Lehtinen. All rights reserved.
//

#import "UploadConnection.h"
#import "HTTPLogging.h"
#import "HTTPMessage.h"
#import "HTTPFileResponse.h"
#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "UploadServer.h"

static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE;

@implementation UploadConnection

@synthesize imageData = _imageData, parser = _parser;

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    NSLog(@"Server supports path=%@ method=%@", path, method);
    if ([path isEqualToString:@"/"] && [method isEqualToString:@"GET"])
    {
        return YES;
    }
    if ([path isEqualToString:@"/upload"] && [method isEqualToString:@"POST"])
    {
        return YES;
    }
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	if ([path isEqualToString:@"/upload"] && [method isEqualToString:@"POST"])
    {
        // Check request content type.
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if (NSNotFound == paramsSeparator)
        {
            return NO;
        }
        if (paramsSeparator >= contentType.length - 1)
        {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if (![type isEqualToString:@"multipart/form-data"])
        {
            return NO;
        }
        
		// Check request boundary.
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for (NSString* param in params)
        {
            paramsSeparator = [param rangeOfString:@"="].location;
            if ((NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1)
            {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            if ([paramName isEqualToString: @"boundary"])
            {
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        if (nil == [request headerField:@"boundary"])
        {
            return NO;
        }
        return YES;
    }
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	if([path isEqualToString:@"/"] && [method isEqualToString:@"GET"])
    {
        NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
		return [[HTTPFileResponse alloc] initWithFilePath:templatePath forConnection:self];
	}
	if ([path isEqualToString:@"/upload"] && [method isEqualToString:@"POST"])
	{
        NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"ok" ofType:@"html"];
        return [[HTTPFileResponse alloc] initWithFilePath:templatePath forConnection:self];
	}
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    NSString* boundary = [request headerField:@"boundary"];
    self.parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    self.parser.delegate = self;
}

- (void)processBodyData:(NSData *)postDataChunk
{
    [self.parser appendData:postDataChunk];
}

- (void)processStartOfPartWithHeader:(MultipartMessageHeader*)header
{
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
	NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    if ((nil != filename) && [[filename lowercaseString] hasSuffix:@".jpg"])
    {
        self.imageData = [[NSMutableData alloc] init];
	}
}

- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*)header
{
	if (self.imageData != nil)
    {
		[self.imageData appendData:data];
	}
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    if (self.imageData != nil)
    {
        UIImage *image = [UIImage imageWithData:self.imageData];
        [[UploadServer sharedServer] addImage:image];
        self.imageData = nil;
    }
}

- (void) processPreambleData:(NSData*)data
{
}

- (void) processEpilogueData:(NSData*)data
{
}

@end
