//
//  FirstViewController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/18/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "MoodViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Spotify/Spotify.h>

@interface MoodViewController ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) NSMutableArray *weatherSongs;
@property (nonatomic, strong) NSString *curWeather;
@property (nonatomic) NSInteger curSongIdx;
@end

@implementation MoodViewController

CLLocationManager *locationManager;
bool userClickPause;

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage new]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:[UIImage new]];
    
    self.weatherSongs = [[NSMutableArray alloc] init];
    self.curSongIdx = -1;
    
    // Check Facebook Login
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
    if(user_id == nil) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
}

- (void) toggleButtons {
    // Check Spotify Login
    NSString *spotify_token = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_token"];
    if(spotify_token == nil) {
        // Spotify connect button
        [self.btnLogin addTarget:self action:@selector(connectButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        self.btnLogin.hidden = NO;
        self.btnPlay.hidden = YES;
        self.btnFavor.hidden = YES;
        self.btnNext.hidden = YES;
    } else {
        self.btnLogin.hidden = YES;
        if(self.curSongIdx != -1) { // Very first appearance of this viewcontroller
            self.btnPlay.hidden = NO;
            self.btnFavor.hidden = NO;
            self.btnNext.hidden = NO;
            userClickPause = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self toggleButtons];
    
    // Init locationManager
    if(locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locationManager startUpdatingLocation];
    }
    
    [self getLocalWeather];
}

// Once the button is clicked, show the login dialog
- (void)connectButtonClicked {
    NSString *spotify_client_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_client_id"];
    [[SPTAuth defaultInstance] setClientID: spotify_client_id];
    NSString *spotify_client_callback = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_client_callback"];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString: spotify_client_callback]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];
    
    // Construct a login URL and open it
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    // Opening a URL in Safari close to application launch may trigger
    // an iOS bug, so we wait a bit before doing so.
    [[UIApplication sharedApplication] performSelector:@selector(openURL:)
                      withObject:loginURL afterDelay:0.1];
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
            self.curWeather = weather_icon;
            float temp_farenheit = [dict[@"result"][@"temperature"] floatValue];
            float temp_celsius = (temp_farenheit - 32 ) / 1.8;
            int temp_f = temp_farenheit + 0.5; // Round it
            int temp_c = temp_celsius + 0.5; // Round it
            NSString *weather_str = [NSString stringWithFormat:@"%@\n%d °C / %d °F", weather_icon, temp_c, temp_f];
            
            // Already got the longitude & latitude, save the battery power
            [locationManager stopUpdatingHeading];
            
            // Already logged in to Spotify, trigger the player
            NSString *spotify_token = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_token"];
            if(spotify_token != nil) {
                [self initSpotifyPlayer:spotify_token];
            }
            
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


- (IBAction)favorSong:(id)sender {
}

- (IBAction)playPauseSong:(id)sender {
    if([self.player isPlaying]) {
        userClickPause = YES;
        [self.btnPlay setBackgroundImage:[UIImage imageNamed:@"ctrl-play"] forState:UIControlStateNormal];
    } else {
        userClickPause = NO;
        [self.btnPlay setBackgroundImage:[UIImage imageNamed:@"ctrl-pause"] forState:UIControlStateNormal];
    }
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
}

- (IBAction)nextSong:(id)sender {
    if([self.weatherSongs count] == 0)
        return;
    
    if(self.curSongIdx == -1) {
        [self.btnPlay setBackgroundImage:[UIImage imageNamed:@"ctrl-pause"] forState:UIControlStateNormal];
    }
    
    self.curSongIdx = (self.curSongIdx + 1) % [self.weatherSongs count];
    NSString *song_uri = [self.weatherSongs objectAtIndex:self.curSongIdx][@"uri"];
    NSURL *url = [NSURL URLWithString: song_uri];
    [self.player playURI:url callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Spotify player failed to play: %@", error);
            return;
        }
    }];
}

- (void)loginUsingSession:(SPTSession *)session {
    self.session = session;
    [self initSpotifyPlayer:session.accessToken];
    [[NSUserDefaults standardUserDefaults] setValue:session.accessToken forKey:@"spotify_token"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.btnLogin.hidden = YES;
    });
}

- (void) initSpotifyPlayer:(NSString*) accessToken {
    // Get the player instance
    self.player = [SPTAudioStreamingController sharedInstance];
    self.player.delegate = self;
    self.player.playbackDelegate = self;
    // Start the player (will start a thread)
    NSString *spotify_client_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_client_id"];
    [self.player startWithClientId:spotify_client_id error:nil];
    // Login SDK before we can start playback
    [self.player loginWithAccessToken: accessToken];
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    // Get a list of tracks by weather keyword
    NSString *api_path = @"https://api.spotify.com/v1/search";
    NSString *kw = [self.curWeather stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    kw = [kw stringByReplacingOccurrencesOfString:@"partly" withString:@""]; // partly is not friendly to Spotify search
    NSDictionary *params = @{
                             @"q": kw,
                             @"type": @"track"
                             };
    NSString *api_url = [api_path stringByAppendingString:[self buildQueryStringFromDictionary:params]];
    NSLog(@"Spotify api_url: %@", api_url);
    NSURL *url = [NSURL URLWithString: api_url];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //NSLog(@"dict:\n %@", dict);
            for(NSDictionary* item in dict[@"tracks"][@"items"]) {
                NSDictionary *song = @{
                                       @"title": item[@"name"],
                                       @"uri": item[@"uri"],
                                       @"artist": item[@"artists"][0][@"name"],
                                       };
                [self.weatherSongs addObject:song];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self nextSong:nil];
            });
        }
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    //NSLog(@"isPlaying: %i, userClickPause: %i", isPlaying, userClickPause);
    if(!isPlaying && !userClickPause) { // Real End of a track
        dispatch_async(dispatch_get_main_queue(), ^{
            [self nextSong:nil];
        });
    }
}

@end
