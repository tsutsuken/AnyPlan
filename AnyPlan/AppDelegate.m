//
//  AppDelegate.m
//  AnyPlan
//
//  Created by Ken Tsutsumi on 13/04/20.
//  Copyright (c) 2013年 Ken Tsutsumi. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#define kVersionNumber @"kVersionNumber"
#define kProjectTitle @"kProjectTitle"
#define kProjectIconImageName @"kProjectIconImageName"
#define kProjectColorHex @"kProjectColorHex"
#define kMixpanelToken @"72593cb7c1133b0ade53cef1b1bd4311"
#define kFlurryApplicationKey @"8PPTHYBKBKJVFF4BK8Y8"
#define kGoogleAnalyticsTrackingId @"UA-42302139-1"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self checkUpdates];
    [self setNotificationCenter];//[MKStoreManager sharedManager]より先である必要がある
    
    [MKStoreManager sharedManager];
    [self setReviewRequestSystem];
    [self setAnalyticsSystem];
    
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    IIViewDeckController *deckController = (IIViewDeckController*) self.window.rootViewController;
    deckController.centerhiddenInteractivity = IIViewDeckCenterHiddenNotUserInteractiveWithTapToCloseBouncing;
    deckController.centerController = [self tabBarController];
    deckController.leftController = [self menuViewNavigationController];
    
    return YES;
}

- (void)setNotificationCenter
{
    //アプリ完全終了時に消えれば良いから、removeは不要
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didResignSubscription:)
                                                 name:kSubscriptionsInvalidNotification object:nil];
}

- (void)setAnalyticsSystem
{
    [Mixpanel sharedInstanceWithToken:kMixpanelToken];
    
    [Flurry startSession:kFlurryApplicationKey];
    
    [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingId];
    
    //Set Top but after all 3rd party
    [Crashlytics startWithAPIKey:@"05bba97476be46a19cd9fe6700e03312cdd38e05"];
}

- (void)setReviewRequestSystem
{
#warning 本番IDを入れる
    [Appirater setAppId:@"523946175"];//LevelUp
    [Appirater setDaysUntilPrompt:2];
    [Appirater setUsesUntilPrompt:4];
    [Appirater setTimeBeforeReminding:2];//「後で」を押された後に、何日間待つか

    [Appirater appLaunched:YES];//didFinishLaunchingWithOptionsの最後に呼ぶ必要がある
    
    //[Appirater setDebug:YES];
}

- (CustomTabBarController *)tabBarController
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    CustomTabBarController *tabBarController = (CustomTabBarController*) [mainStoryBoard instantiateViewControllerWithIdentifier:@"CenterTabBarController"];
    tabBarController.managedObjectContext = self.managedObjectContext;
    tabBarController.shouldDisplayAllProject = YES;
    
    return tabBarController;
}

- (UINavigationController *)menuViewNavigationController
{
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"MenuViewNavigationController"];
    
    MenuViewController *menuViewController = (MenuViewController *)navigationController.topViewController;
    menuViewController.managedObjectContext = self.managedObjectContext;
    [menuViewController.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection: 0]
                                              animated:NO
                                        scrollPosition:UITableViewScrollPositionNone];

    return navigationController;
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - MKStorekit Delegate

- (void)didResignSubscription:(NSNotification *)notification
{
    LOG(@"didResignSubscription_%@", [notification object]);
    
    NSString *productId = [notification object];
    
    if ([productId isEqualToString:kProductIdSubscriptionMonth])
    {
        [ANALYTICS trackEvent:kEventResignPremiumMonth isImportant:YES sender:self];
    }
    else
    {
        [ANALYTICS trackEvent:kEventResignPremiumYear isImportant:YES sender:self];
    }
    
    [ANALYTICS registerSuperProperties:@{kPropertyKeyAccountType:kPropertyValueAccountTypeFree}];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        //http://www.slideshare.net/hedjirog/core-data-14134061
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        //_managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"AnyPlan" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"AnyPlan.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Update

- (void)checkUpdates
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float loadedVersion = [[defaults objectForKey:kVersionNumber] floatValue];
    
    float bundleVersion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue];
    
    LOG(@"loaded_%f",loadedVersion);
    LOG(@"bundle_%f",bundleVersion);
    
    if (loadedVersion == bundleVersion)//現在のバージョンを起動したことがある場合
    {
        //何もしない
    }
    else
    {
        if (!loadedVersion)//一度も起動したことがない場合
        {
            [self insertDefaultProjects];
        }
        
        // 現在のバンドルバージョンを記録
        [defaults setObject:[NSNumber numberWithFloat:bundleVersion] forKey:kVersionNumber];
        [defaults synchronize];
    }
}

- (void)insertDefaultProjects
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DefaultProjects" ofType:@"plist"];
    NSArray *defaultProjectDataArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    int maxProjectCount = [defaultProjectDataArray count];//4
    int projectCount = (int)(arc4random() % maxProjectCount) + 1;
    [ANALYTICS registerSuperProperties:@{kPropertyKeyDefaultProjectCount:[NSNumber numberWithInt:projectCount]}];
    //projectCount = maxProjectCount;
    
    for (int i = 0; i < projectCount; i++)
    {
        NSDictionary *dictionary = [defaultProjectDataArray objectAtIndex:i];
        
        Project *project = (Project *)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
        project.displayOrder = [NSNumber numberWithInt:i];
        project.title = [dictionary objectForKey:@"title"];
        project.colorHex = [dictionary objectForKey:@"colorHex"];
        
        NSString *iconName = [dictionary objectForKey:@"iconName"];
        project.icon = [UIImage imageNamed:iconName];
    }
    
    [self saveContext];
}

#pragma mark - Methods For Other Class

- (NSFetchedResultsController *)fetchedResultsControllerForProjectWithContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    return aFetchedResultsController;
}

- (NSString *)mainTitleForTabBarWithProject:(Project *)project shouldDisplayAllProject:(BOOL)shouldDisplayAllProject
{
    NSString *mainTitle;
    
    if (shouldDisplayAllProject)
    {
        mainTitle = NSLocalizedString(@"Common_Project_Category_All", nil);
    }
    else
    {
        mainTitle = project.title;
    }
    
    return mainTitle;
}

- (Project *)inboxProjectInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *projectArray = [context executeFetchRequest:fetchRequest error:&error];
    
    return [projectArray objectAtIndex:0];
}

- (BOOL)isPremiumUser
{
    BOOL isPremiumUser;
    
    if ([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionMonth])
    {
        isPremiumUser = YES;
    }
    else if([[MKStoreManager sharedManager] isSubscriptionActive:kProductIdSubscriptionYear])
    {
        isPremiumUser = YES;
    }
    else
    {
        isPremiumUser = NO;
    }

    return isPremiumUser;
}

- (BOOL)canAddNewProject
{
#warning test
    LOG_BOOL([self isPremiumUser], @"isPremiumUser");
    
    BOOL canAddNewProject;
    
    int numberOfCustomProject = [self numberOfCustomProject];
    
    if (numberOfCustomProject < kMaxNumberOfCustomProject)
    {
        canAddNewProject = YES;
    }
    else
    {
        if ([self isPremiumUser])
        {
            canAddNewProject = YES;
        }
        else
        {
            canAddNewProject = NO;
        }
    }
    
    return canAddNewProject;
}

- (int)numberOfCustomProject
{
    int numberOfCustomProject;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
    
    numberOfCustomProject = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil] - 1;//未分類プロジェクトの分を引く
    
    return numberOfCustomProject;
}

@end
