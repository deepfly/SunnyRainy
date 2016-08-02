//
//  FindController.h
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/22/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PlaySongViewController.h"
#import "MoodViewController.h"

@interface FindController : UIViewController<MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation *anno;
@property (nonatomic) NSInteger *first;
@property (copy, nonatomic) NSArray* hosts;
@property (copy, nonatomic) NSString* selectedHostID;
@property (strong, nonatomic) IBOutlet UIButton *curLocButton;


@end
