//
//  AppDelegate.m
//  Pelotonia
//
//  Created by Mark Harris on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "RiderDataController.h"
#import "Pelotonia-Colors.h"
#import "Appirater.h"
#import "NSDictionary+JSONConversion.h"
#import "ProfileTableViewController.h"
#import "PelotoniaProfileViewController.h"
#import "RidersViewController.h"
#import "InitialSlidingViewController.h"
#import "MenuViewController.h"
#import <Socialize/Socialize.h>

#define SYSTEM_VERSION_GREATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation AppDelegate

@synthesize window = _window;
@synthesize riderDataController = _riderDataController;


- (void)handleNotification:(NSDictionary*)userInfo {
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        for (NSString *key in [userInfo allKeys]) {
            NSLog(@"userInfo[%@] = %@", key, [userInfo objectForKey:key]);
        }
        NSDictionary *socializeDictionary = [userInfo objectForKey:@"socialize"];
        NSString *notificationType = [socializeDictionary objectForKey:@"notification_type"];
        NSLog(@"Notification type: %@", notificationType);
        

        if ([SZSmartAlertUtils openNotification:userInfo]) {
            NSLog(@"Socialize handled the notification (background).");
            
        } else {
            NSLog(@"Socialize did not handle the notification (background).");
            
        }
    } else {
        
        NSLog(@"Notification received in foreground");
        
        // You may want to display an alert or other popup instead of immediately opening the notification here.
        
        if ([SZSmartAlertUtils openNotification:userInfo]) {
            NSLog(@"Socialize handled the notification (foreground).");
        } else {
            NSLog(@"Socialize did not handle the notification (foreground).");
        }
    }
}

- (void)register {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)registerForRemoteNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if(!error){
            [self performSelectorOnMainThread:@selector(register) withObject:nil waitUntilDone:true];
        }
    }];
}

- (void)setDefaultAppearance {
    // set default appearance
    [[UIButton appearance] setTintColor:PRIMARY_GREEN];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowBlurRadius = 0.0;
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: SECONDARY_LIGHT_GRAY,
                                                           NSShadowAttributeName: shadow,
                                                           NSFontAttributeName: PELOTONIA_FONT_BOLD(21),
                                                           }];
    [[UINavigationBar appearance] setTintColor: PRIMARY_GREEN];
    [[UINavigationBar appearance] setBarTintColor:PRIMARY_DARK_GRAY];
    [[UINavigationBar appearance] setBackgroundColor:PRIMARY_DARK_GRAY];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = SECONDARY_LIGHT_GRAY;
    pageControl.currentPageIndicatorTintColor = SECONDARY_GREEN;
    pageControl.backgroundColor = [UIColor clearColor];
}

- (void)setupSocialize:(NSDictionary *) launchOptions {
    
    // set the socialize api key and secret, register your app here: http://www.getsocialize.com/apps/
    [Socialize storeLocationSharingDisabled:YES];
    [Socialize storeConsumerKey:@"26caf692-9893-4f89-86d4-d1f1ae45eb3b"];
    [Socialize storeConsumerSecret:@"6b070689-31a9-4f5a-907e-4422d87a9e42"];
    [SZFacebookUtils setAppId:@"269799726466566"];
    [SZTwitterUtils setConsumerKey:@"5wwPWS7GpGvcygqmfyPIcQ" consumerSecret:@"95FOLBeQqgv0uYGMWewxf50U0sVAVIbVBlvsmjiB4V8"];
    
    // Specify a Socialize entity loader block
    [Socialize setEntityLoaderBlock:^(UINavigationController *navigationController, id<SocializeEntity>entity) {
        NSDictionary *metaDict = [NSDictionary dictionaryWithContentsOfJSONString:[entity meta]];
        NSString *riderID = [metaDict objectForKey:@"riderID"];
        
        if ([riderID isEqualToString:@"PELOTONIA"]) {
            // this is the pelotonia entity
            // navigate to the riders view controller & show the profile
            InitialSlidingViewController *rvc = (InitialSlidingViewController *)self.window.rootViewController;
            UINavigationController *nvc = (UINavigationController *)rvc.topViewController;
            
            PelotoniaProfileViewController *pelotoniaVC = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"PelotoniaProfileViewController"];
            
            if (navigationController == nil)
            {
                [nvc pushViewController:pelotoniaVC animated:YES];
            } else {
                [navigationController pushViewController:pelotoniaVC animated:YES];
            }
        }
        else {
            Rider *rider = [[Rider alloc] initWithName:[entity name] andId:riderID];
            rider.profileUrl = [entity key];
            
            [rider refreshFromWebOnComplete:^(Rider *rider) {
                
                // navigate to the riders view controller & show the profile
                InitialSlidingViewController *rvc = (InitialSlidingViewController *)self.window.rootViewController;
                UINavigationController *nvc = (UINavigationController *)rvc.topViewController;
                
                ProfileTableViewController *profileViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"ProfileTableViewController"];
                profileViewController.rider = rider;
                
                if (navigationController == nil)
                {
                    [nvc pushViewController:profileViewController animated:YES];
                } else {
                    [navigationController pushViewController:profileViewController animated:YES];
                }
            } onFailure:^(NSString *errorMessage) {
                NSLog(@"Unknown Rider: %@. Error: %@", [entity name], errorMessage);
            }];
        }
    }];
    
    // Handle Socialize notification at launch
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil) {
        [self handleNotification:userInfo];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // Register for Apple Push Notification Service
    [self registerForRemoteNotifications];

    // Initialize our coredata instance
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"PelotoniaModel"];

    // clear the SDWebImageCache
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];

    [self setDefaultAppearance];
    
    // set the socialize api key and secret, register your app here: http://www.getsocialize.com/apps/
    [self setupSocialize:launchOptions];
    
    // setup Appirater
    [Appirater setAppId:@"550038050"];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:3];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
        
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Handle Socialize notification at foreground
    [self handleNotification:userInfo];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken
{
    // If you are testing development (sandbox) notifications, you should instead pass development:YES
    NSLog(@"device token:%@", deviceToken);
#if DEBUG
    [SZSmartAlertUtils registerDeviceToken:deviceToken development:YES];
#else
    [SZSmartAlertUtils registerDeviceToken:deviceToken development:NO];
#endif
}


- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self archiveData];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}


// data controller methods
#pragma mark -- data controller
+ (NSString *)PelotoniaFiles:(NSString *)fileName
{
    // get list of directories in sandbox
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    // get the only directory from the list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    // append passed in file name to the return value
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

+ (NSString *)riderFilePath
{
    return [AppDelegate PelotoniaFiles:@"Riders"];
}

- (RiderDataController *)riderDataController {
    return [AppDelegate sharedDataController];
}

+ (PelotoniaPhotosLibrary *)pelotoniaPhotoLibrary
{
    static PelotoniaPhotosLibrary *photoLibrary = nil;

    if (photoLibrary == nil) {
        photoLibrary = [[PelotoniaPhotosLibrary alloc] init];
        [photoLibrary album:^(PHAssetCollection * _Nonnull album) {
            NSLog(@"Created album successfully!");
        }];
    }
    
    return photoLibrary;
}

- (void)archiveData
{
    // get the game list & write it out
    [NSKeyedArchiver archiveRootObject:self.riderDataController toFile:[AppDelegate riderFilePath]];
}

+ (RiderDataController *)sharedDataController
{
    static RiderDataController *dataController = nil;
    
    if (dataController == nil)
    {
        dataController = [NSKeyedUnarchiver unarchiveObjectWithFile:[self riderFilePath]];
        if (dataController == nil) {
            dataController = [[RiderDataController alloc] init];
        }
    }
    return dataController;
}

#pragma mark - open URL stuff

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [Socialize handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [Socialize handleOpenURL:url];
}





@end
