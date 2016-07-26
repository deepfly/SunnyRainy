//
//  FirstViewController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/18/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "MoodViewController.h"

@interface MoodViewController ()
@property (strong, nonatomic) IBOutlet UITextView *temperatureText;
@property (strong, nonatomic) IBOutlet UIImageView *weatherImage;
@property (strong, nonatomic) IBOutlet UIView *playerContainer;

@end

@implementation MoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    
    [self getLocalWeather];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getLocalWeather {
    // retrieve the api host, e.g. http://127.0.0.1:8000/api/
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    NSString *api_url = [api_host stringByAppendingString:@"weather"];
    //NSLog(@"api_host: %@\napi_url: %@", api_host, api_url);
    NSURL *url = [NSURL URLWithString: api_url];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //NSLog(@"dict:\n %@", dict);
            NSString* weather_icon = dict[@"result"][@"currently"][@"icon"];
            float temp_farenheit = [dict[@"result"][@"currently"][@"temperature"] floatValue];
            float temp_celsius = (temp_farenheit - 32 ) / 1.8;
            int temp_f = temp_farenheit + 0.5; // Round it
            int temp_c = temp_celsius + 0.5; // Round it
            NSString *weather_str = [NSString stringWithFormat:@"%@\n%d °C / %d °F", weather_icon, temp_c, temp_f];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblWeather.text = weather_str;
            });
        }
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];
}

@end
