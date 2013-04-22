//
//  ServerViewController.m
//  CameraArray
//

#import "ServerViewController.h"
#import "UploadedImage.h"

@implementation ServerViewController

@synthesize images = _images, updateTimer = _updateTimer;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        self.images = [NSMutableArray arrayWithCapacity:MAX_IMAGE_COUNT + 1];
        self.updateTimer = nil;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    UploadServer *server = [UploadServer sharedServer];
    [server setDelegate:self];
    if (![server start])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hosting failed!" message:@"Could not create a server socket and register a Bonjour service." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_TIME target:self selector:@selector(updateFromTimer:) userInfo:nil repeats:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UploadServer sharedServer] stopWithFinish:YES];
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    for (UploadedImage *image in self.images)
    {
        [image.view removeFromSuperview];
    }
    [self.images removeAllObjects];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)server:(UploadServer *)server receivedImage:(UploadedImage *)image
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image.image];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        imageView.alpha = 1.0;
    }];
    image.view = imageView;
    [self.images addObject:image];
    [self.view addSubview:imageView];
    [self updateImages];
}

- (void)updateFromTimer:(NSTimer *)timer
{
    [self updateImages];
}

- (void)updateImages
{
    NSInteger remove_count = self.images.count - MAX_IMAGE_COUNT;
    NSMutableArray *removedImages = [NSMutableArray array];
    NSDate *dateLimit = [NSDate dateWithTimeIntervalSinceNow:-KEEP_TIME];
    for (UploadedImage *image in self.images)
    {
        if (remove_count > 0 || [image.date compare:dateLimit] == NSOrderedAscending)
        {
            [image.view removeFromSuperview];
            [removedImages addObject:image];
            remove_count--;
        }
    }
    for (UploadedImage *image in removedImages)
    {
        [self.images removeObject:image];
    }
    #ifdef DEBUG
    NSLog(@"Removed %d images.", removedImages.count);
    #endif
    [self repositionImages];
}

- (void)repositionImages
{
    #ifdef DEBUG
    NSLog(@"Positioning visible %d images.", self.images.count);
    #endif
    NSUInteger count = self.images.count;
    CGSize size = self.view.frame.size;
    BOOL isLandscape = size.width > size.height;
    NSLog(@"w=%f h=%f landscape=%d", size.width, size.height, isLandscape);
    if (count == 1)
    {
        [self positionImageWithIndex:0 x:0 y:0 w:size.width h:size.height];
    }
    else if (count == 2)
    {
        if (isLandscape)
        {
            CGFloat xHalf = size.width / 2;
            [self positionImageWithIndex:0 x:0 y:0 w:xHalf h:size.height];
            [self positionImageWithIndex:1 x:xHalf y:0 w:xHalf h:size.height];
        }
        else
        {
            CGFloat yHalf = size.height / 2;
            [self positionImageWithIndex:0 x:0 y:0 w:size.width h:yHalf];
            [self positionImageWithIndex:1 x:0 y:yHalf w:size.width h:yHalf];
        }
    }
    else if (count == 3)
    {
        if (isLandscape)
        {
            CGFloat xHalf = size.width / 2;
            CGFloat yHalf = size.height / 2;
            [self positionImageWithIndex:0 x:0 y:0 w:xHalf h:size.height];
            [self positionImageWithIndex:1 x:xHalf y:0 w:xHalf h:yHalf];
            [self positionImageWithIndex:2 x:xHalf y:yHalf w:xHalf h:yHalf];
        }
        else
        {
            CGFloat xHalf = size.width / 2;
            CGFloat yHalf = size.height / 2;
            [self positionImageWithIndex:0 x:0 y:0 w:size.width h:yHalf];
            [self positionImageWithIndex:1 x:0 y:yHalf w:xHalf h:yHalf];
            [self positionImageWithIndex:2 x:xHalf y:yHalf w:xHalf h:yHalf];
        }
    }
    else if (count == 4)
    {
        CGFloat xHalf = size.width / 2;
        CGFloat yHalf = size.height / 2;
        [self positionImageWithIndex:0 x:0 y:0 w:xHalf h:yHalf];
        [self positionImageWithIndex:1 x:0 y:yHalf w:xHalf h:yHalf];
        [self positionImageWithIndex:2 x:xHalf y:0 w:xHalf h:yHalf];
        [self positionImageWithIndex:3 x:xHalf y:yHalf w:xHalf h:yHalf];
    }
    else if (count == 5)
    {
        if (isLandscape)
        {
            CGFloat xThird = size.width / 3;
            CGFloat yHalf = size.height / 2;
            [self positionImageWithIndex:0 x:xThird y:0 w:xThird h:size.height];
            [self positionImageWithIndex:1 x:0 y:0 w:xThird h:yHalf];
            [self positionImageWithIndex:2 x:0 y:yHalf w:xThird h:yHalf];
            [self positionImageWithIndex:3 x:2 * xThird y:0 w:xThird h:yHalf];
            [self positionImageWithIndex:4 x:2 * xThird y:yHalf w:xThird h:yHalf];
        }
        else
        {
            CGFloat yThird = size.height / 3;
            CGFloat xHalf = size.width / 2;
            [self positionImageWithIndex:0 x:0 y:yThird w:size.width h:yThird];
            [self positionImageWithIndex:1 x:0 y:0 w:xHalf h:yThird];
            [self positionImageWithIndex:2 x:xHalf y:0 w:xHalf h:yThird];
            [self positionImageWithIndex:3 x:0 y:2 * yThird w:xHalf h:yThird];
            [self positionImageWithIndex:4 x:xHalf y:2 * yThird w:xHalf h:yThird];
        }
    }
}

- (void)positionImageWithIndex:(NSUInteger)index x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h
{
    UploadedImage *image = [self.images objectAtIndex:index];
    image.view.frame = CGRectMake(x, y, w, h);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self repositionImages];
}

- (IBAction)viewTapped:(id)sender {
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

@end
