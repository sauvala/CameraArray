//
//  UploadServer.m
//  CameraArray
//

#import "UploadServer.h"
#import "UploadConnection.h"
#import "UploadedImage.h"

@implementation UploadServer

@synthesize started = _started, serverName = _serverName, server = _server, images = _images, delegate = _delegate;

+ (UploadServer *)sharedServer
{
    static UploadServer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.started = NO;
        self.serverName = nil;
        self.server = [[HTTPServer alloc] init];
        [self.server setType:SERVICE_TYPE];
        [self.server setConnectionClass:[UploadConnection class]];
        self.images = [NSMutableArray array];
    }
    return self;
}

- (BOOL)start
{
    [self stopWithFinish:YES];
    if (self.serverName != nil)
    {
        [self.server setName:self.serverName];
        NSError *error;
        if ([self.server start:&error])
        {
            self.started = YES;
            [self.images removeAllObjects];
            #if DEBUG
            NSLog(@"Started HTTP server on port %hu", [self.server listeningPort]);
            #endif
            return YES;
        }
        else
        {
            #if DEBUG
            NSLog(@"Error starting HTTP server: %@", error);
            #endif
        }
    }
    return NO;
}

- (void)stopWithFinish:(BOOL)finish
{
    if ([self.server isRunning])
    {
        #if DEBUG
        NSLog(@"Stopping HTTP server.");
        #endif
        [self.server stop];
    }
    if (finish)
    {
        self.started = NO;
    }
}

- (void)addImage:(UIImage *)image
{
    #if DEBUG
    NSLog(@"Received new image.");
    #endif
    UploadedImage *upImage = [UploadedImage uploadedImageWithImage:image];
    [self.images addObject:upImage];
    if (self.delegate != nil)
    {
        [self.delegate server:self receivedImage:upImage];
    }
}

@end
