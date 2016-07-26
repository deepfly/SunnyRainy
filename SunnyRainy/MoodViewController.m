//
//  FirstViewController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/18/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "MoodViewController.h"

@interface MoodViewController ()

@end

@implementation MoodViewController

CLLocationManager *locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    
    // Init locationManager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
    
    [self getLocalWeather];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getLocalWeather {
    // retrieve latitude & longitude
    float latitude = locationManager.location.coordinate.latitude;
    float longitude = locationManager.location.coordinate.longitude;
    NSDictionary *params = @{
                             @"latitude": [[NSNumber numberWithFloat:latitude] stringValue],
                             @"longitude": [[NSNumber numberWithFloat:longitude] stringValue]
                             };
    
    // retrieve the api host, e.g. http://127.0.0.1:8000/api/
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    NSString *api_path = [api_host stringByAppendingString:@"weather"];
    NSString *api_url = [api_path stringByAppendingString:[self buildQueryStringFromDictionary:params]];
    NSLog(@"api_url: %@", api_url);
    NSURL *url = [NSURL URLWithString: api_url];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //NSLog(@"dict:\n %@", dict);
            NSString* weather_icon = dict[@"result"][@"icon"];
            float temp_farenheit = [dict[@"result"][@"temperature"] floatValue];
            float temp_celsius = (temp_farenheit - 32 ) / 1.8;
            int temp_f = temp_farenheit + 0.5; // Round it
            int temp_c = temp_celsius + 0.5; // Round it
            NSString *weather_str = [NSString stringWithFormat:@"%@\n%d °C / %d °F", weather_icon, temp_c, temp_f];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblWeather.text = weather_str;
                self.imgWeather.image = [UIImage imageNamed:weather_icon];
            });
        }
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];
}

-(NSString *) buildQueryStringFromDictionary:(NSDictionary *)parameters {
    NSString *urlVars = @"";
    for (NSString *key in parameters) {
        NSString *value = parameters[key];
        value = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSString *tmp = [NSString stringWithFormat:@"%@%@=%@", urlVars.length > 0 ? @"&": @"", key, value];
        urlVars = [urlVars stringByAppendingString:tmp];
    }
    return [NSString stringWithFormat:@"%@%@", urlVars ? @"?" : @"", urlVars ? urlVars : @""];
}

@end
