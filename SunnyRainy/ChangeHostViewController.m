//
//  ChangeHostViewController.m
//  SunnyRainy
//
//  Created by lidonghui on 7/28/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "ChangeHostViewController.h"

@interface ChangeHostViewController ()

@end

@implementation ChangeHostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    self.txtHost.text = api_host;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveHost:(id)sender {
    NSString *new_api_host = self.txtHost.text;
    if (![new_api_host hasPrefix:@"http"]) {
        [self alert:@"Error" and:@"API host must starts with 'http://' or 'https://'."];
        return;
    }
    if (![new_api_host hasSuffix:@"/api/"]) {
        [self alert:@"Error" and:@"API host must ends with '/api/'."];
        return;
    }
    
    // set the api_host
    [[NSUserDefaults standardUserDefaults] setValue:new_api_host forKey:@"api_host"];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)alert:(NSString *)title and:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: title
                                                                             message: message
                                                                      preferredStyle:UIAlertControllerStyleAlert                   ];
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alertController addAction: ok];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
