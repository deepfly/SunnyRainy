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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)showHosts:(id)sender {
    
}

- (IBAction)createHost:(id)sender {
//    [self performSegueWithIdentifier:@"createHost" sender:self];
}

@end
