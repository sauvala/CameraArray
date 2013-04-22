//
//  HostViewController.m
//  CameraArray
//

#define SERVER_SEGUE @"server"

#import "HostViewController.h"
#import "UploadServer.h"

@implementation HostViewController

@synthesize nameTextField = _nameTextField, deviceNameLabel = _deviceNameLabel, serverName = _serverName;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // Find out the device name.
    UIDevice *device = [UIDevice currentDevice];
    [self.deviceNameLabel setText:device.name];
    
    // Close keyboard if touched on background.
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.nameTextField action:@selector(resignFirstResponder)];
	gestureRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:gestureRecognizer];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Close keyboard once clicked "done".
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)startHost:(id)sender
{
    // Start hosting a camera array session with given name.
    NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (name.length > 0)
    {
        self.serverName = name;
        [self performSegueWithIdentifier:SERVER_SEGUE sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SERVER_SEGUE])
    {
        [[UploadServer sharedServer] setServerName:[NSString stringWithFormat:@"%@&d=%@", self.serverName, self.deviceNameLabel.text]];
    }
}

@end
