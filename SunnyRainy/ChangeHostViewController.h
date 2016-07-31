//
//  ChangeHostViewController.h
//  SunnyRainy
//
//  Created by lidonghui on 7/28/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeHostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *txtHost;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)saveHost:(id)sender;

@end
