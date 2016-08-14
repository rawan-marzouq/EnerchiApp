//
//  ViewController.m
//  emPower App
//
//  Created by Rawan on 1/17/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "ViewController.h"
#import <Security/Security.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // here for alert user if the session is terminal
    self.view.backgroundColor = [UIColor blackColor];
    NSString*msg=[[NSUserDefaults standardUserDefaults] objectForKey:@"message"];
    
        if (msg!=nil &&[msg isEqualToString: @"AlertMessage"]) {
        [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"message"];
        NSInteger numOfDay = [[NSUserDefaults standardUserDefaults] integerForKey:@"numDay"];
        float min;
        NSString*typeDayOrMinutes=[[NSUserDefaults standardUserDefaults] objectForKey: @"typeDayOrMinutes"];
        if ([typeDayOrMinutes isEqualToString: @"Days"]) {
            min=(numOfDay/(60*60*24));
            
        }else {
            min=numOfDay/(60);
        }

            
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"please login again" message:[NSString stringWithFormat:@"%@: %.2f%@",@"you must refresh you account every",min,typeDayOrMinutes] delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    

    //[self];
    // loading view is hidden by default]
    self.loadingView.hidden = YES;
}

#pragma mark - IBActions
- (IBAction)LoginProviderPressed:(id)sender
{
    
    if ([self.usernameTxt.text isEqualToString:@""] || [self.passwordTxt.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing data", nil)
                                                        message:NSLocalizedString(@"Please, enter your user name and password then press login.\n Or try to login as Demo", )
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    // login
    // backend with Authentication
    [self loginWithUserName:self.usernameTxt.text Password:self.passwordTxt.text];


}
- (IBAction)demoLogin:(id)sender
{
    
    
    // login
    // backend with Authentication
    [self loginAsDemo];
    
}
// sign out button
// for testing issues
// hidden to the user
- (IBAction)SignOutPressed:(id)sender
{
    NSLog(@"Logged out");
}
#pragma mark - UITextField
// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 10 );
}
// keypad disappear
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
#pragma mark - Backend
-(void)loginAsDemo
{
    NSLog(@"backend loginAsDemo");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/users/loginAsDemo"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     
     {
         
         if (data.length > 0 && connectionError == nil)
         {
             NSError *error = nil;
             id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingMutableContainers
                                                                error:&error];
             
             NSLog(@"callResult: %@",jsonObjects);
             NSString *token = [jsonObjects objectForKey:@"id"];
             NSString *tTL=[jsonObjects objectForKey:@"ttl"];
             NSLog(@"token: %@",token);
             NSLog(@"TTL:%@",tTL);
             
             
            //here to to take ttl value from web service and add it to now date.
             numDay=[tTL intValue];
             now=[NSDate date];
             finalDate=[now dateByAddingTimeInterval:numDay];
             
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
            [self saveUsername:@"" andPassword:@"" withToken:token];
             
             [[NSUserDefaults standardUserDefaults] setObject:finalDate forKey:@"finalDate"];
             [[NSUserDefaults standardUserDefaults] setObject:@" minutes" forKey:@"typeDayOrMinutes"];
             [[NSUserDefaults standardUserDefaults] setInteger:numDay forKey:@"numDay"];

             // loading...
             self.loadingView.hidden = NO;
             //Navigate to the Categories View
             UIViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
             [self presentViewController:loginVC animated:YES completion:nil];
             
             
             if (error) {
                 NSLog(@"error is %@", [error localizedDescription]);
                 // Handle Error and return
                 return;
             }
             
         }
         
         else
             
         {
  
             NSLog(@"connectionError: %@", connectionError);
             
         }
         
     }];
}




-(void)generalLoginUsername:(NSString*)username Password:(NSString*)password
{
    if ([username isEqualToString:@""] || [password isEqualToString:@""])
    {
        // backend Demo Authentication
        [self loginAsDemo];
        
        
    }
    else
    {
        // backend with Authentication
        [self loginWithUserName:username Password:password];
    }
}
-(void)loginWithUserName:(NSString*)username Password:(NSString*)password
{
    
    
    NSLog(@"backend Authentication");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/users/login"]];
    
    NSString *jSONString = [NSString stringWithFormat:@"{\"username\":\"%@\" ,\"password\":\"%@\"}", username,password];
    NSData *credintials = [jSONString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSLog(@"credintials: %@", jSONString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    [request setHTTPBody:credintials];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     
     {
         
         if (data.length > 0 && connectionError == nil)
         {
             NSError *error = nil;
             id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingMutableContainers
                                                                error:&error];
             
             
             
             if (error) {
                 NSLog(@"error is %@", [error localizedDescription]);
                 // Handle Error and return
                 return;
             }
             
             NSLog(@"callResult jsonObjects: %@",jsonObjects);
             NSString *token = [jsonObjects objectForKey:@"id"];
             NSLog(@"token: %@",token);
             NSString *tTL=[jsonObjects objectForKey:@"ttl"];
             
             [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
            [self saveUsername:username andPassword:password withToken:token];
             
                         //             NSLog(@"data: %@",[data description]);
             
             // loading...
             self.loadingView.hidden = NO;
             
             //here to to take ttl value from web service and add it to now date.
             numDay=[tTL intValue];
             now=[NSDate date];
             finalDate=[now dateByAddingTimeInterval:numDay];
      
             [[NSUserDefaults standardUserDefaults] setInteger:numDay forKey:@"numDay"];
             [[NSUserDefaults standardUserDefaults] setObject:finalDate forKey:@"finalDate"];
             [[NSUserDefaults standardUserDefaults] setObject:@"Days" forKey:@"typeDayOrMinutes"];


             //Navigate to the Categories View
             UIViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
             [self presentViewController:loginVC animated:YES completion:nil];
         }
         
         else
             
         {

             NSLog(@"connectionError: %@", connectionError);
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Username/Password", nil)
                                                             message:NSLocalizedString(@"Please, enter a valid username & password", )
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                   otherButtonTitles:nil];
             [alert show];
             
             return;
         }
         
     }];
}

#pragma mark - Keychain

-(void)saveUsername:(NSString*)username andPassword:(NSString*)password withToken:(NSString*)token
{

    //Let's create an empty mutable dictionary:
    NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];

    NSString *website = @"server";
    
    //Populate it with the data and the attributes we want to use.
    
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword; // We specify what kind of keychain item this is.
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked; // This item can only be accessed when the user unlocks the device.
    keychainItem[(__bridge id)kSecAttrServer] = website;
    
    //Check if this keychain item already exists.
    keychainItem[(__bridge id)kSecAttrAccount] = username;

    if(SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, NULL) == noErr)
    {
        NSLog(@"userSaved: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"The Item Already Exists", nil)
//                                                        message:NSLocalizedString(@"Please update it instead.", )
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                              otherButtonTitles:nil];
//        [alert show];
        
        
    }else
    {
        keychainItem[(__bridge id)kSecValueData] = [token dataUsingEncoding:NSUTF8StringEncoding]; //Our password
        
       OSStatus sts = SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
    NSLog(@"Error Code: %d", (int)sts);
        
    }
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",username] forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];

   }

#pragma mark - Memory managment
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
