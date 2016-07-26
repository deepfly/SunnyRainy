//
//  ChooseSongViewController.h
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/22/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseSongViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property(copy, nonatomic) NSArray* songs;
@property(copy, nonatomic) NSMutableDictionary *songsDict;
@property(copy, nonatomic) NSArray *songSectionTitles;
@property(nonatomic) NSInteger* selectedRow;

@end
