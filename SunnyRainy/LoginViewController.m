//
//  LoginViewController.m
//  SunnyRainy
//
//  Created by lidonghui on 7/26/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Facebook login
    [self.btnLogin addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Once the button is clicked, show the login dialog
- (void)loginButtonClicked {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Facebook Log in error: %@", error);
         } else if (result.isCancelled) {
             NSLog(@"Facebook Log in cancelled");
         } else {
             [self getUserProfile];
         }
     }];
}

- (void)getUserProfile {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"name, picture"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 //NSLog(@"fetched user:%@", result);
                 NSString *user_name = result[@"name"];
                 NSString *fb_id = result[@"id"];
                 NSString *avatar = [[NSString alloc] initWithFormat: @"http://graph.facebook.com/%@/picture?type=large", fb_id];
                 
                 NSLog(@"name: %@, fb_id: %@, avatar: %@", user_name, fb_id, avatar);
                 
                 // Save local user info
                 [[NSUserDefaults standardUserDefaults] setValue:user_name forKey:@"user_name"];
                 [[NSUserDefaults standardUserDefaults] setValue:avatar forKey:@"avatar"];
                 
                 // Save server user info
                 NSMutableDictionary *mdict = [[NSMutableDictionary alloc] init];
                 mdict[@"name"] = user_name;
                 mdict[@"fb_id"] = fb_id;
                 mdict[@"avatar"] = avatar;
                 [self ensureUserServerInfo:mdict];
             }
         }];
    }
}

- (void) ensureUserServerInfo:(NSDictionary *) parameters {
    // retrieve the api host, e.g. http://127.0.0.1:8000/api/
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    NSString *api_url = [api_host stringByAppendingString:@"user/ensure"];
    NSURL *url = [NSURL URLWithString: api_url];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = [NSString stringWithFormat:@"nickname=%@&fb_id=%@&avatar=%@", parameters[@"name"], parameters[@"fb_id"], parameters[@"avatar"]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask * task =[defaultSession dataTaskWithRequest:urlRequest
       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if( error) {
               NSLog(@"error: %@", error);
           } else {
               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
               [[NSUserDefaults standardUserDefaults] setValue:dict[@"user_id"] forKey:@"user_id"];
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
               });

           }
       }];
    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
