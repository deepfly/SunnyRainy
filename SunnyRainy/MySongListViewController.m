//
//  MySongListViewController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/20/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "MySongListViewController.h"

@interface MySongListViewController ()

@end

@implementation MySongListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _songsDict = [NSMutableDictionary new];
    [self getUserSongs];
}

- (void) getUserSongs {
    // Check Facebook Login
    NSString *user_id = [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"];
    if(user_id == nil) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    // retrieve the api host, e.g. http://127.0.0.1:8000/api/
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    NSString *api_str = [NSString stringWithFormat:@"user/%@/songs", user_id];
    NSString *api_url = [api_host stringByAppendingString:api_str];
    NSLog(@"api_url: %@", api_url);
    NSURL *url = [NSURL URLWithString: api_url];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray* songs = dict[@"songs"];
            for (NSDictionary *songinfo in songs) {
                NSString *uniq_id = [NSString stringWithFormat:@"%@-%@", user_id, songinfo[@"url"]];
                if(![[NSUserDefaults standardUserDefaults] objectForKey:uniq_id]) continue;
                
                NSString *key = [[songinfo[@"title"] substringToIndex:1] capitalizedString];
                NSMutableArray *arr;
                if([_songsDict objectForKey:key]){
                    arr = [_songsDict objectForKey:key];
                } else {
                    arr = [NSMutableArray new];
                    [_songsDict setObject:arr forKey:key];
                }
                
                [arr addObject:songinfo];
            }
            _songSectionTitles = [[_songsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _songSectionTitles;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return [_songSectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_songSectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    NSString *sectionTitle = [_songSectionTitles objectAtIndex:section];
    NSArray *sectionSongs = [_songsDict objectForKey:sectionTitle];
    return [sectionSongs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *simpleIdentifier = @"songCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleIdentifier];
    }
    NSString *sectionTitle = [_songSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionSongs = [_songsDict objectForKey:sectionTitle];
    NSDictionary *songInfo = [sectionSongs objectAtIndex:indexPath.row];
    
    NSString *songName = songInfo[@"title"];
    cell.textLabel.text = songName;
    NSString *length = songInfo[@"duration"];
    int lint = [length intValue];
    NSString *artist = songInfo[@"artist"];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Length: %i min %i s  Artist: %@", lint/60, lint%60, artist];
    cell.tag = [((NSString *)songInfo[@"id"]) intValue];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView cellForRowAtIndexPath:indexPath].selected = false;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Is this my Alert View?
    if (buttonIndex == 0) {// Cancel Button
        
    }
    else if (buttonIndex == 1) {// OK Button
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

@end
