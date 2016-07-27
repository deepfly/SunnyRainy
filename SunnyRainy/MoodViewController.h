//
//  FirstViewController.h
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/18/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVAudioPlayer.h> 
#import <Spotify/Spotify.h>

@interface MoodViewController : UIViewController <SPTAudioStreamingDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgWeather;
@property (weak, nonatomic) IBOutlet UILabel *lblWeather;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnFavor;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)favorSong:(id)sender;
- (IBAction)playPauseSong:(id)sender;
- (IBAction)nextSong:(id)sender;

- (void) loginUsingSession:(SPTSession *)session;
- (void) toggleButtons;

@end

