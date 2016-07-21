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
    self.PersonalInfo = @[@"Ziping Zheng", @"@ZipingMobile"];
//    personTableView.scroll
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *simpleIdentifier = @"SimpleIdentifier";
    if(indexPath.section == 0 && indexPath.row == 0){
        simpleIdentifier = @"PortraitCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleIdentifier];
    }
    
    NSInteger *idx = [indexPath row];
    if(indexPath.section == 0){
        if (idx == 0) {
            UIImageView *portraitView = ((PortraitCell *)cell).portraitImg;
            portraitView.image = [UIImage imageNamed:@"sun_strong_bold"];
            [portraitView.layer setBorderColor: [[UIColor blackColor] CGColor]];
            [portraitView.layer setBorderWidth: 0.1];
            portraitView.layer.cornerRadius = 10;
            portraitView.clipsToBounds = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"Portrait:"];
        } else if (idx == 1){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"Nick name: %@", _PersonalInfo[0]];
        } else if (idx == 2){
            cell.textLabel.text = [NSString stringWithFormat:@"Twitter account: %@", _PersonalInfo[1]];
        }
    } else if(indexPath.section == 1){
        if (idx == 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"My favourie lists"];
        }
    }
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger *idx = [indexPath row];
    if (indexPath.section == 0) {
        if(idx == 0){
            [self performSegueWithIdentifier:@"changePortrait" sender:self];
        } else if(idx == 1){
            [self performSegueWithIdentifier:@"changeName" sender:self];
        }
    } else if (indexPath.section == 1 && idx == 0){
        [self performSegueWithIdentifier:@"myFavourite" sender:self];
    }
    
    [tableView cellForRowAtIndexPath:indexPath].selected = false;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0)
        return 100;
    
    return 75;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        
        return 25;
    }
    else
        return 0;
    
}

@end
