//
//  FindController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/22/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "FindController.h"
#import "PlaySongViewController.h"

@interface FindController () <MKMapViewDelegate>{
    CLLocationManager *clm;
}
    
@end

@implementation FindController

float MAP_SPAN = 0.05;
float AVAILABLE_RADIUS = 1000;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [_mapView setDelegate:self];
    [_mapView setZoomEnabled:YES];
    [_mapView setScrollEnabled:YES];
    
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
    
    [self.curLocButton.layer setShadowOffset:CGSizeMake(5, 5)];
    [self.curLocButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.curLocButton.layer setShadowOpacity:0.5];

    [self retriveHosts];
    
    _first = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    id<MKAnnotation> ann = [mapView.selectedAnnotations objectAtIndex:0];
    CLLocationCoordinate2D coord = ann.coordinate;
//    NSLog(@"coord: lan: %f, lon: %f", coord.latitude, coord.longitude);
    CLLocation *col = [CLLocation alloc];
    [col initWithLatitude:coord.latitude longitude:coord.longitude];
    
    CLLocationCoordinate2D coord2 = [_mapView userLocation].coordinate;
//    NSLog(@"coord2: lan: %f, lon: %f", coord2.latitude, coord2.longitude);
    CLLocation *col2 = [CLLocation alloc];
    [col2 initWithLatitude:coord2.latitude longitude:coord2.longitude];
    double distance = [col2 distanceFromLocation:col];
    
    [mapView deselectAnnotation:view.annotation animated:YES];
    if (![(MKAnnotationView *)view.annotation isKindOfClass:[MKUserLocation class]]){
//        MapAnnotation *annotation = view.annotation;
        UITabBarController *tabBar = (UITabBarController *) self.navigationController.tabBarController;
//        [tabBar setSelectedIndex:0];
        MoodViewController *fcontroller = (MoodViewController *)[[tabBar viewControllers][0] childViewControllers][0];
        
        if([fcontroller.player isPlaying])
            [fcontroller playPauseSong:fcontroller];
        
        NSLog( (MKAnnotationView *)view.annotation.title);
        _selectedHostID = (MKAnnotationView *)view.annotation.title;
        
        
        NSLog(@"dist: %f", distance);
        if (distance > AVAILABLE_RADIUS) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too far away"
                                                            message:@"You need to get closer to join that music host" delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            [self performSegueWithIdentifier:@"playSong" sender:nil];
        }
    }
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    if (_first == 0) {
        _first = 1;
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        
        span.latitudeDelta = MAP_SPAN;
        span.longitudeDelta = MAP_SPAN;
        
        CLLocationCoordinate2D location;
        location.latitude = aUserLocation.coordinate.latitude;
        location.longitude = aUserLocation.coordinate.longitude;
        
        region.span = span;
        region.center = location;
        [_mapView setRegion:region animated:YES];
        
        //add a circle around user's location to indicate whether a music host is available or not
        [_mapView removeOverlays:[_mapView overlays]];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:location radius:AVAILABLE_RADIUS];
        [_mapView addOverlay:circle];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    NSString *spotify_token = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_token"];
    if (spotify_token == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Haven't login to Spotify"
                                                        message:@"You need to log in to Spotify first to play song in a host" delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
        //        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];

    
    if ([segue.identifier isEqualToString:@"playSong"]) {
        PlaySongViewController* psvc = (PlaySongViewController*)segue.destinationViewController;
        psvc.hostId = _selectedHostID;
        
    }
}

- (IBAction)showHosts:(id)sender {
    [self retriveHosts];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                    message:@"All music hosts nearby are retrieved" delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
            
            [_mapView removeAnnotations:_mapView.annotations];
            
            for (NSDictionary *hostinfo in _hosts) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
                float lat = [(NSNumber *)hostinfo[@"latitude"] floatValue];
                float lon = [(NSNumber *)hostinfo[@"longitude"] floatValue];
                NSLog(@"%f, %f", lat, lon);
                annotation.coordinate = CLLocationCoordinate2DMake(lat, lon);
                annotation.title = [NSString stringWithFormat:@"%i", [(NSNumber *)hostinfo[@"id"] integerValue]];
                [_mapView addAnnotation:annotation];
            }
            
            [_mapView setCenterCoordinate:_mapView.region.center animated:YES];
        }
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];  
}

- (IBAction)createHost:(id)sender {
    [self performSegueWithIdentifier:@"createHost" sender:self];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
//    circleView.strokeColor = [UIColor blueColor];
    circleView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.1];
    return circleView;
}

- (IBAction)zoomToCurrentLocation:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = MAP_SPAN;
    span.longitudeDelta = MAP_SPAN;
    
    region.span = span;
    region.center = [[_mapView userLocation] coordinate];
    [_mapView setRegion:region animated:YES];
    
    //add a circle around user's location to indicate whether a music host is available or not
    [_mapView removeOverlays:[_mapView overlays]];
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:_mapView.userLocation.coordinate radius:AVAILABLE_RADIUS];
    [_mapView addOverlay:circle];
}

@end
