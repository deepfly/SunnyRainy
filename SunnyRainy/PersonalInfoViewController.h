//
//  SecondViewController.h
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/18/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PortraitCell.h"

@interface PersonalInfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *personTableView;
//@property (strong, nonatomic) IBOutlet UITableView *songTableView;
@property(copy, nonatomic) NSArray* PersonalInfo;

@end

