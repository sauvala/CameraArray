/*
 *  JoinViewController.m
 *  CameraArray
 *
 *  Search and join to a photoshoot session
 *
 *
 *
 */


#define CELL_ID @"Service"
#define RESOLVE_TIMEOUT_SEC 5

#import "JoinViewController.h"
#import "CameraViewController.h"
#import "UploadServer.h"

@implementation JoinViewController

@synthesize serviceBrowser = _serviceBrowser, services = _services, selected = _selected;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.services = [NSMutableArray array];
        self.serviceBrowser = nil;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self startSearch];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //[self stopSearch];
    [self hideActivityIndicator];
}


// Search services
- (void)startSearch
{
    [self stopSearch];
    [self showActivityIndicator];
    [self.services removeAllObjects];
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    if (self.serviceBrowser)
    {
        [self.serviceBrowser setDelegate:self];
        [self.serviceBrowser searchForServicesOfType:SERVICE_TYPE inDomain:@""];
        #if DEBUG
        NSLog(@"NSServiceBrowser searching.");
        #endif
    }
}

- (void)stopSearch
{
    if (self.serviceBrowser != nil)
    {
        [self.serviceBrowser stop];
        [self.serviceBrowser setDelegate:nil];
        #if DEBUG
        NSLog(@"NSServiceBrowser stopped.");
        #endif
    }
    [self hideActivityIndicator];
}


// Service found
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    #if DEBUG
    NSLog(@"NSNetService found: %@", netService);
    #endif
    if (![self.services containsObject:netService])
    {
        [self.services addObject:netService];
    }
    if (!moreServicesComing)
    {
        [self.tableView reloadData];
        [self hideActivityIndicator];
    }
}

// Remove service
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    #if DEBUG
    NSLog(@"NSNetService removed: %@", netService);
    #endif
    [self.services removeObject:netService];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    #ifdef DEBUG
    return [self.services count] + 1;
    #endif
    return [self.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID forIndexPath:indexPath];
    if (indexPath.row >= [self.services count])
    {
        [cell.textLabel setText:@"(Fake Server)"];
        [cell.detailTextLabel setText:@"Debug build only"];
    }
    else
    {
        NSNetService* service = [self.services objectAtIndex:indexPath.row];
        NSArray *names = [service.name componentsSeparatedByString:@"&d="];
        [cell.textLabel setText:[names objectAtIndex:0]];
        if (names.count > 1)
        {
            [cell.detailTextLabel setText:[names objectAtIndex:1]];
        }
        else
        {
            [cell.detailTextLabel setText:@""];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.services count])
    {
        self.selected = nil;
        [self netServiceDidResolveAddress:nil];
    }
    else
    {
        self.selected = [self.services objectAtIndex:indexPath.row];
        [self.selected setDelegate:self];
        [self.selected resolveWithTimeout:RESOLVE_TIMEOUT_SEC];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    #if DEBUG
    NSLog(@"Service address resolved.");
    #endif
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    #if DEBUG
    NSLog(@"Service not resolved!");
    #endif
    [self showAlertWithTitle:@"Host stopped!" message:@"Could not resolve the service address."];
}

- (void)showActivityIndicator
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)hideActivityIndicator
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
