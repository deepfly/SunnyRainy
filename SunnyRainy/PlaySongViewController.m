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
    self.curSongIdx = -1;
    
    NSLog(_hostId);
    
    // Check Facebook Login
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
    if(user_id == nil) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    NSString *spotify_token = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_token"];
    //    else ;
}

- (void)viewWillAppear:(BOOL)animated {
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.player stop:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) toggleButtons {
    // Check Spotify Login
    NSString *spotify_token = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_token"];
    if(spotify_token == nil) {
        // Spotify connect button
        [self.buttonLogin addTarget:self action:@selector(connectButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        self.buttonLogin.hidden = NO;
        self.buttonPlay.hidden = YES;
        self.buttonFavor.hidden = YES;
        self.buttonNext.hidden = YES;
    } else {
        self.buttonLogin.hidden = YES;
        if(self.curSongIdx != -1) { // Very first appearance of this viewcontroller
            self.buttonPlay.hidden = NO;
            self.buttonFavor.hidden = NO;
            self.buttonNext.hidden = NO;
            userClickPause2 = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self toggleButtons];
    // Already logged in to Spotify, trigger the player
    NSString *spotify_token = [[NSUserDefaults standardUserDefaults] valueForKey:@"spotify_token"];
    if(spotify_token != nil) {
        _songID = nil;
        _slotSongID = nil;
        self.weatherSongs = [[NSMutableArray alloc] init];
        [self initSpotifyPlayer:spotify_token];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Haven't login to Spotify"
                                                        message:@"You need to log in to Spotify first to play song in a host" delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    // Get a list of tracks by weather keyword
    [self addSong:@"3ZYbZ7kVjyiQPV6LnbNHUG"];
}


- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    //NSLog(@"isPlaying: %i, userClickPause: %i", isPlaying, userClickPause);
    if(!isPlaying && !userClickPause2) { // Real End of a track
        dispatch_async(dispatch_get_main_queue(), ^{
            [self nextSong:nil];
        });
    }
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

- (void) changeIntoFavoredButton {
    favoredButton2 = YES;
    [self.buttonFavor setBackgroundImage:[UIImage imageNamed:@"ctrl-plus-pink"] forState:UIControlStateNormal]; // Pink it!
}

- (void) changeIntoNormalButton {
    favoredButton2 = NO;
    [self.buttonFavor setBackgroundImage:[UIImage imageNamed:@"ctrl-plus"] forState:UIControlStateNormal]; // Unpink it!
}

- (IBAction)nextSong:(id)sender {
    NSLog(@"songs count: %i", _weatherSongs.count);
    if([self.weatherSongs count] == 0)
        return;
    
    if(self.curSongIdx == -1) {
        [self.buttonPlay setBackgroundImage:[UIImage imageNamed:@"ctrl-pause"] forState:UIControlStateNormal];
    }
    
    self.curSongIdx = (self.curSongIdx + 1) % [self.weatherSongs count];
    NSDictionary* song = [self.weatherSongs objectAtIndex:self.curSongIdx];
    
    NSURL *imgurl = [NSURL URLWithString:song[@"image_url"]];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imgurl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data){
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _imgView.image = image;
                });
            }
        }
        if (error) {
            NSLog(@"Error: %@", error);
        }
    }];
    [task resume];
    
    _label.text = [NSString stringWithFormat:@"%@ by %@",song[@"title"], song[@"artist"] ];
    
    NSString *song_uri = song[@"uri"];
    NSURL *url = [NSURL URLWithString: song_uri];
    NSLog(song_uri);
    [self.player playURI:url callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Spotify player failed to play: %@", error);
            return;
        }
    }];
    
    // Check Favor mark
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
    NSString *uniq_id = [NSString stringWithFormat:@"%@-%@", user_id, song_uri];
    NSString *favor_mark = [[NSUserDefaults standardUserDefaults] valueForKey:uniq_id];
    if (favor_mark != nil) { // It's a favored song
        // Change the Favor Button
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeIntoFavoredButton];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeIntoNormalButton];
        });
    }
}

- (void)loginUsingSession:(SPTSession *)session {
    self.session = session;
    [self initSpotifyPlayer:session.accessToken];
    [[NSUserDefaults standardUserDefaults] setValue:session.accessToken forKey:@"spotify_token"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.buttonLogin.hidden = YES;
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
    
    [self getHostSongs];
    
    playerInited2 = YES;
}

- (void)getHostSongs {
    // retrieve the api host, e.g. http://127.0.0.1:8000/api/
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    NSString *api_str = [NSString stringWithFormat:@"host/%@", _hostId];
    NSString *api_url = [api_host stringByAppendingString:api_str];
    NSLog(@"api_url: %@", api_url);
    NSURL *url = [NSURL URLWithString: api_url];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSDictionary *host = dict[@"host"];
            
            _songID = host[@"song_id"];
//            _slotSongID = host[@"slot_song_id"];
            [self retrieveSongURI:_songID];
        }
        
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];
}

- (void)retrieveSongURI:(NSString*)songID{
    // retrieve the api host, e.g. http://127.0.0.1:8000/api/
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    NSString *api_str = [NSString stringWithFormat:@"song/%@", songID];
    NSString *api_url = [api_host stringByAppendingString:api_str];
    NSLog(@"api_url: %@", api_url);
    NSURL *url = [NSURL URLWithString: api_url];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"song"];
            NSRange range = [(NSString*)dict[@"url"] rangeOfString:@":" options:NSBackwardsSearch];
            NSLog(@"range.location: %lu", range.location);
            NSString* songURI = [dict[@"url"] substringFromIndex:(range.location + 1)];
            NSLog(@"_songURI: %@", songURI);
            [self addSong:songURI];
        }
        
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];
}

- (void)addSong:(NSString*)songURI {
    NSString *api_path = @"https://api.spotify.com/v1/tracks/";
    NSString *api_url = [api_path stringByAppendingString:songURI];
    NSLog(@"Spotify api_url: %@", api_url);
    NSURL *url = [NSURL URLWithString: api_url];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"dict:\n %@", dict);
//            for(NSDictionary* item in dict[@"tracks"][@"items"]) {
            NSDictionary *song = @{
                                   @"title": dict[@"name"],
                                   @"uri": dict[@"uri"],
                                   @"artist": dict[@"artists"][0][@"name"],
                                   @"duration": [@([dict[@"duration_ms"] intValue] / 1000) stringValue],
                                   @"image_url": dict[@"album"][@"images"][0][@"url"]
                                   };
            [self.weatherSongs addObject:song];
        }
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self nextSong:nil];
            });
//        }
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];
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
