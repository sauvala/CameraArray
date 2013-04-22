//
//  CameraViewController.h
//  CameraArray
//

#import <UIKit/UIKit.h>
#import "JoinViewController.h"

@interface CameraViewController : JoinViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSURLConnection *connection;

- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate;
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)cancel;
- (void)sendImageToServer:(UIImage *)image;
- (void)sendTestImageToServer;

@end
