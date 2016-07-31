//
//  MySongListViewController.h
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/20/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySongListViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property(copy, nonatomic) NSArray* songs;
@property(copy, nonatomic) NSMutableDictionary *songsDict;
@property(copy, nonatomic) NSArray *songSectionTitles;

@end
