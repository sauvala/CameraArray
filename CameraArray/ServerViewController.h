//
//  ServerViewController.h
//  CameraArray
//

#define MAX_IMAGE_COUNT 5
#define UPDATE_TIME 60
#define KEEP_TIME 180

#import <UIKit/UIKit.h>
#import "UploadServer.h"

@interface ServerViewController : UIViewController <UploadServerDelegate>

@property (strong) NSMutableArray *images;
@property (weak) NSTimer *updateTimer;

- (void)updateFromTimer:(NSTimer *)timer;
- (void)updateImages;
- (void)repositionImages;
- (void)positionImageWithIndex:(NSUInteger)index x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h;
- (IBAction)viewTapped:(id)sender;

@end
