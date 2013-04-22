//
//  HostViewController.h
//  CameraArray
//

#import <UIKit/UIKit.h>

@interface HostViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (strong, nonatomic) NSString *serverName;

- (IBAction)startHost:(id)sender;

@end
