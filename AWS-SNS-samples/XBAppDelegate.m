//
//  XBAppDelegate.m
//  AWS-SNS-samples
//
//  Created by Martin Moizard on 21/08/13.
//  Copyright (c) 2013 Martin Moizard. All rights reserved.
//

#import "XBAppDelegate.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

#define kXBRemotePushTokenBaseUrl (@"http://aws-sns-server.tom404.cloudbees.net")
#define kXBRemovePushTokenRegistrationEndpoint (@"/registrations/apns")

@implementation XBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    UIApplication *app = [UIApplication sharedApplication];
    UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |
                                                 UIRemoteNotificationTypeAlert;
    [app registerForRemoteNotificationTypes:notificationTypes];
    
    return YES;
}

#pragma mark - APNS

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)rawDeviceToken
{
	const unsigned *tokenBytes = [rawDeviceToken bytes];
	NSString *deviceToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
							 ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
							 ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
							 ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSLog(@"APNS : Device token : %@", deviceToken);

	[self updateDeviceTokenOnServer:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error
{
	NSLog(@"APNS: Failed to register with error: %@", error);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSLog(@"APNS: Received push: %@", userInfo);
}

- (void)updateDeviceTokenOnServer:(NSString *)deviceToken
{
	NSURL *url = [NSURL URLWithString:kXBRemotePushTokenBaseUrl];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];

	[httpClient putPath:kXBRemovePushTokenRegistrationEndpoint parameters:nil
				success:^(AFHTTPRequestOperation *operation, id responseObject) {
					NSLog(@"Token updated on server");
				}
				failure:^(AFHTTPRequestOperation *operation, NSError *error) {
					NSLog(@"Fail to update token on server : %@", error);
				}];
}

@end
