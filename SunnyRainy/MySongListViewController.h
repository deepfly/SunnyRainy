//
//  MySongListViewController.h
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/20/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySongListViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property(copy, nonatomic) NSArray* songs;

@end
