//
//  PlaySongViewController.h
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/30/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaySongViewController : UIViewController

@property(copy, nonatomic) NSString* hostId;
@property (strong, nonatomic) IBOutlet UIButton *buttonLogin;
@property (strong, nonatomic) IBOutlet UIButton *buttonPlay;
@property (strong, nonatomic) IBOutlet UIButton *buttonFavor;
@property (strong, nonatomic) IBOutlet UIButton *buttonNext;

@end
