//
//  SecondViewController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/18/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import <Spotify/Spotify.h>

@interface PersonalInfoViewController ()

@end

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *avatar = [[NSUserDefaults standardUserDefaults] valueForKey:@"avatar"];
    self.imgAvatar.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatar]]];
    
    [self.imgAvatar.layer setShadowOffset:CGSizeMake(5, 5)];
    [self.imgAvatar.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [self.imgAvatar.layer setShadowOpacity:0.5];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *simpleIdentifier = @"InfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleIdentifier];
    }
    
    NSInteger idx = [indexPath row];
    if (idx == 0) {
        NSString *user_name = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_name"];
        cell.detailTextLabel.text = @"Name";
        cell.textLabel.text = user_name;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if(idx == 1) {
        cell.textLabel.text = @"Favorite Songs";
        cell.detailTextLabel.text = @"Songs favored in Mood Player";
    } else if(idx == 2) {
        cell.textLabel.text = @"API Host";
        cell.detailTextLabel.text = @"Server host of SunnyRainy";
    } else if(idx == 3) {
        cell.textLabel.text = @"Log out";
        cell.textLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger idx = [indexPath row];
    if(idx == 2) {
        [self performSegueWithIdentifier:@"changeHost" sender:self];
    } else if (idx == 1) {
        [self performSegueWithIdentifier:@"showFavorite" sender:self];
    } else if (idx == 3) {
        [self clearUserInfo];
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    [tableView cellForRowAtIndexPath:indexPath].selected = false;
}

- (void) clearUserInfo {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spotify_token"];
    [[SPTAudioStreamingController sharedInstance] logout];
}

@end
