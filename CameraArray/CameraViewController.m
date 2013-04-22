//
//  CameraViewController.m
//  CameraArray
//

#import "CameraViewController.h"

@implementation CameraViewController

@synthesize connection = _connection;

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    #if DEBUG
    NSLog(@"Service address resolved and starting camera.");
    #endif
    if (![self startCameraControllerFromViewController:self usingDelegate:self])
    {
        [self showAlertWithTitle:@"Camera required!" message:@"Your device does not report to have a camera."];
    }
}

- (BOOL)startCameraControllerFromViewController:(UIViewController*)controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (delegate == nil)|| (controller == nil))
    {
        #ifdef DEBUG
        [self sendTestImageToServer];
        #endif
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.allowsEditing = NO;
    
    // Create custom toolbar.
    cameraUI.showsCameraControls = NO;
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, size.height - 60, size.width, 60)];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Stop" style:UIBarButtonItemStyleBordered target:self action: @selector(cancel)];
    UIBarButtonItem *flexibleBarSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cameraBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:cameraUI action:@selector(takePicture)];
    toolbar.items = [NSArray arrayWithObjects:cancelBarButtonItem, flexibleBarSpace, cameraBarButtonItem, flexibleBarSpace, nil];
    [cameraUI setCameraOverlayView:toolbar];
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController: cameraUI animated: YES completion:nil];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self sendImageToServer:image];
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendImageToServer:(UIImage *)image
{
    NSURL *url = nil;
    if (self.selected == nil)
    {
        url = [NSURL URLWithString:@"http://localhost:80/upload"];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/upload", self.selected.hostName, self.selected.port]];
    }
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\"photo.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:UIImageJPEGRepresentation(image, 0.9)];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    #if DEBUG
    NSLog(@"Created request body of length %.1f kb", (float) body.length / 1024);
    #endif
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%d", body.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:body];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    #if DEBUG
    NSLog(@"Started URLConnection to %@", url);
    #endif
}

- (void)sendTestImageToServer
{
    [self sendImageToServer:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Grumpy-Cat" ofType:@"jpg"]]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    #if DEBUG
    NSLog(@"URLConnection failed with error: %@", error);
    #endif
    [self showAlertWithTitle:@"Sending photo failed!" message:@"A photo you captured earlier could not reach the host."];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    #if DEBUG
    NSLog(@"URLConnection success (finished loading).");
    #endif
}

@end
