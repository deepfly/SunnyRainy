//
//  SecondViewController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/18/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "PersonalInfoViewController.h"

@interface PersonalInfoViewController ()

@end

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *avatar = [[NSUserDefaults standardUserDefaults] valueForKey:@"avatar"];
    self.imgAvatar.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatar]]];
    
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *simpleIdentifier = @"InfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleIdentifier];
    }
    
    NSInteger idx = [indexPath row];
    if (idx == 0){
        NSString *user_name = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_name"];
        cell.detailTextLabel.text = @"Name";
        cell.textLabel.text = user_name;
    } else if(idx == 1){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Favorite Songs";
        cell.detailTextLabel.text = @"Songs favored in Mood Player";
    }
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger idx = [indexPath row];
    if(idx == 0){
        [self performSegueWithIdentifier:@"changeName" sender:self];
    } else if (idx == 1){
        [self performSegueWithIdentifier:@"myFavourite" sender:self];
    }
    
    [tableView cellForRowAtIndexPath:indexPath].selected = false;
}

@end
