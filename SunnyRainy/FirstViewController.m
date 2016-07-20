//
//  FirstViewController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/18/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (strong, nonatomic) IBOutlet UITextView *temperatureText;
@property (strong, nonatomic) IBOutlet UIImageView *weatherImage;
@property (strong, nonatomic) IBOutlet UIView *playerContainer;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//    NSURL *fileURL = [NSURL init]
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] init];
//    playerViewController.player = audioPlayer;
    [self addChildViewController:playerViewController];
//    [self.playerContainer addSubview:playerViewController.view];
    playerViewController.view.frame = CGRectMake(0, 0, self.playerContainer.frame.size.width, self.playerContainer.frame.size.height);
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Song List"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(showList)];
    self.navigationItem.rightBarButtonItem = flipButton;
}

- (void)showList{
    [self performSegueWithIdentifier:@"songlist" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
