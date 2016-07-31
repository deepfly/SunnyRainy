//
//  PlaySongViewController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/30/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <Spotify/Spotify.h>
#import "PlaySongViewController.h"

@interface PlaySongViewController ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) NSMutableArray *weatherSongs;
@property (nonatomic) NSInteger curSongIdx;
@end

@implementation PlaySongViewController

bool userClickPause2 = NO;
bool favoredButton2 = NO;
bool playerInited2 = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.weatherSongs = [[NSMutableArray alloc] init];
    self.curSongIdx = -1;
    
    NSLog(_hostId);
    
    // Check Facebook Login
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
    if(user_id == nil) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void) toggleButtons {
//    // Check Spotify Login
//    NSString *spotify_token = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_token"];
//    if(spotify_token == nil) {
//        // Spotify connect button
//        [self.buttonLogin addTarget:self action:@selector(connectButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//        self.buttonLogin.hidden = NO;
//        self.buttonPlay.hidden = YES;
//        self.buttonFavor.hidden = YES;
//        self.buttonNext.hidden = YES;
//    } else {
//        self.buttonLogin.hidden = YES;
//        if(self.curSongIdx != -1) { // Very first appearance of this viewcontroller
//            self.buttonPlay.hidden = NO;
//            self.buttonFavor.hidden = NO;
//            self.buttonNext.hidden = NO;
//            userClickPause = NO;
//        }
//    }
//}

- (void)viewDidAppear:(BOOL)animated {
//    [self toggleButtons];
    
//    [self getLocalWeather];
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
