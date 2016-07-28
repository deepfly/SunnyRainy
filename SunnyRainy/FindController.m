//
//  FindController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/22/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "FindController.h"

@interface FindController () <MKMapViewDelegate>{
    CLLocationManager *clm;
}
    
@end

@implementation FindController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [CLLocationManager requestAlwaysAuthorization];
    // Do any additional setup after loading the view.
    
    [_mapView setZoomEnabled:YES];
    _mapView.delegate = self;
    [_mapView setScrollEnabled:YES];
    [_mapView setDelegate:self];
    _mapView.showsUserLocation = YES;
    
    clm = [[CLLocationManager alloc] init];
    clm.distanceFilter = kCLDistanceFilterNone;
    clm.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        if ([clm respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [clm requestWhenInUseAuthorization];
    }
    [clm startUpdatingLocation];

    float latitude = clm.location.coordinate.latitude;
    float longitude = clm.location.coordinate.longitude;
    
    _first = 0;
}

//- (void)viewWillAppear:(BOOL)animated {
//    _first = 0;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    if (_first == 0) {
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.02;
        span.longitudeDelta = 0.02;
        CLLocationCoordinate2D location;
        location.latitude = aUserLocation.coordinate.latitude;
        location.longitude = aUserLocation.coordinate.longitude;
        region.span = span;
        region.center = location;
        [aMapView setRegion:region animated:YES];
        _first = 1;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)showHosts:(id)sender {
    [self retriveHosts];
}

- (void) retriveHosts {
    // retrieve the api host, e.g. http://127.0.0.1:8000/api/
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    NSString *api_str = [NSString stringWithFormat:@"host/scan"];
    NSString *api_url = [api_host stringByAppendingString:api_str];
    NSLog(@"api_url: %@", api_url);
    NSURL *url = [NSURL URLWithString: api_url];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            _hosts = dict[@"hosts"];
            
            for (NSDictionary *hostinfo in _hosts) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
                float lat = [(NSNumber *)hostinfo[@"latitude"] floatValue];
                float lon = [(NSNumber *)hostinfo[@"longitude"] floatValue];
                NSLog(@"%f, %f", lat, lon);
                annotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
                [_mapView addAnnotation:annotation];
            }
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.mapView ref];
//            });
        }
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];
}

- (IBAction)createHost:(id)sender {
//    [self performSegueWithIdentifier:@"createHost" sender:self];
}

@end
