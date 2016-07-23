//
//  SelectSongListViewController.h
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/22/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectSongListViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property(copy, nonatomic) NSArray* songLists;
@property(copy, nonatomic) NSArray* timeLists;

@end
