//
//  AppDelegate.m
//  emPower App
//
//  Created by Rawan on 1/17/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "AppDelegate.h"
//#import "AmazonClientManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"didfinishlaunchingwithoption");
    // Override point for customization after application launch.
    NSLog(@"Launch... %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]);
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        // Delete all keychain values
        NSLog(@"wipeAll");
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else{
        
    }

    [self selectInitialViewController];
    return YES;
}

//refresh app ui
-(void)selectInitialViewController{
 
    

    NSLog(@"Refresh UI");
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EnerchiStoryboard" bundle:nil];
    UIViewController *rootController;
  

    NSLog(@"condition: %i",[self isUsernameAndPasswordValid]);
    if([self isUsernameAndPasswordValid]){

        rootController = [storyboard instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
    }else{
        rootController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
}

-(BOOL)isUsernameAndPasswordValid
{
    //Let's create an empty mutable dictionary:
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *website = @"server";

    NSLog(@"username: %@", username);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"username"]) {
        //Populate it with the data and the attributes we want to use.
        keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword; // We specify what kind of keychain item this is.
        keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked; // This item can only be accessed when the user unlocks the device.
        keychainItem[(__bridge id)kSecAttrServer] = website;
        keychainItem[(__bridge id)kSecAttrAccount] = username;
        
        //Check if this keychain item already exists.
        keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
        keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
        
        CFDictionaryRef result = nil;
        
        OSStatus sts = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
        
        NSLog(@"Error Code: %d", (int)sts);
        
        if(sts == noErr)
        {
            NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
            NSData *pswd = resultDict[(__bridge id)kSecValueData];
            NSString *token = [[NSString alloc] initWithData:pswd encoding:NSUTF8StringEncoding];
            
            NSLog(@"Password: %@",token);
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
            return YES;
        }else
        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"The Item Doesn't Exist", nil)
//                                                            message:NSLocalizedString(@"No keychain item found for this user.", )
//                                                           delegate:nil
//                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                                  otherButtonTitles:nil];
//            [alert show];
            return NO;
        }
    }
    return NO;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"application will resign active");
  
   
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"application did enter backgroune");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"EnerchiStoryboard" bundle:nil];
    UIViewController *rootController;
    NSDate*date;
    date=[[NSUserDefaults standardUserDefaults] valueForKey:@"finalDate"];
    // date =[[NSDate date] dateByAddingTimeInterval:1];
    now=[NSDate date];
    
    NSLog(@"condition: %i",[self isUsernameAndPasswordValid]);
    NSComparisonResult result = [now compare:date];

    if(result==NSOrderedAscending){
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"message"];

        rootController = [storyboard instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
    }else if(date!=nil){
        [[NSUserDefaults standardUserDefaults]setObject:@"AlertMessage" forKey:@"message"];
        NSLog(@"hi");
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"finalDate"];
        rootController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }
    else{
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"finalDate"];
        rootController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationwillterminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
