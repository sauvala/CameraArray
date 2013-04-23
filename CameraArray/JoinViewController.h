/*
 *  JoinViewController.h
 *  CameraArray
 *  Search and join to a photoshoot session
 *
 *
 *
 */

#import <UIKit/UIKit.h>

@interface JoinViewController : UITableViewController <NSNetServiceBrowserDelegate, UITableViewDataSource, UITableViewDelegate, NSNetServiceDelegate>

@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetService *selected;

- (void)startSearch;
- (void)stopSearch;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
