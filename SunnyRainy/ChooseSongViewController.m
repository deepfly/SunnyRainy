//
//  ChooseSongViewController.m
//  SunnyRainy
//
//  Created by Ziping Zheng on 7/22/16.
//  Copyright © 2016 Ziping Zheng. All rights reserved.
//

#import "ChooseSongViewController.h"

@interface ChooseSongViewController ()

@end

@implementation ChooseSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _songsDict = [NSMutableDictionary new];
    [self getUserSongs];
//    self.songs = @[@"Camel", @"Cockatoo", @"Dog", @"Donkey", @"Emu", @"Giraffe", @"Greater Rhea", @"Hippopotamus", @"Horse", @"Koala", @"Lion", @"Llama", @"Manatus", @"Meerkat", @"Panda", @"Peacock", @"Pig", @"Platypus", @"Polar Bear", @"Rhinoceros", @"Seagull", @"Tasmania Devil", @"Whale", @"Whale Shark", @"Wombat", @"Buffalo", @"Bear", @"Black Swan"];
//    _songs = [_songs sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    
//
//    
//    for (NSString *str in _songs) {
//        NSString *key = [[str substringToIndex:1] capitalizedString];
//        NSMutableArray *arr;
//        if([_songsDict objectForKey:key]){
//            arr = [_songsDict objectForKey:key];
//        } else {
//            arr = [NSMutableArray new];
//        }
//        NSDictionary *toAdd = [NSDictionary dictionaryWithObject:str forKey:@"title"];
//        [arr addObject:toAdd];
//        [_songsDict setObject:arr forKey:key];
//    }
//    
//    _songSectionTitles = [[_songsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (void) getUserSongs {
    // retrieve the api host, e.g. http://127.0.0.1:8000/api/
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    NSInteger *user_id = 1;
    NSString *api_str = [NSString stringWithFormat:@"user/%i/songs", user_id];
    NSString *api_url = [api_host stringByAppendingString:api_str];
    NSLog(@"api_url: %@", api_url);
    NSURL *url = [NSURL URLWithString: api_url];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray* songs = dict[@"songs"];
            for (NSDictionary *songinfo in songs) {
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Length: %i min %i s", lint/60, lint%60];
    cell.tag = [((NSString *)songInfo[@"id"]) intValue];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *sectionTitle = [_songSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionSongs = [_songsDict objectForKey:sectionTitle];
    NSString *songName = [sectionSongs objectAtIndex:indexPath.row][@"title"];
    NSString *msg = [NSString stringWithFormat:@"Do you really want to use \"%@\" to create your host?", songName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose this song"
                                                    message:msg delegate:self cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    alert.tag = [[tableView cellForRowAtIndexPath:indexPath] tag];
    [alert show];

    [tableView cellForRowAtIndexPath:indexPath].selected = false;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Is this my Alert View?
    if (buttonIndex == 0) {// Cancel Button
//       [self submitData];
    }
    else if (buttonIndex == 1) {// OK Button
        [self createHostWithSong: alertView.tag];
    }
}

- (void) createHostWithSong:(NSInteger *)song_id{
    NSInteger *user_id = 1;
    float latitude = 40.0;
    float longitude = 140.0;
    
    
    // retrieve the api host, e.g. http://127.0.0.1:8000/api/
    NSString *api_host = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_host"];
    NSString *api_str = [NSString stringWithFormat:@"host/create"];
    NSString *api_url = [api_host stringByAppendingString:api_str];
    NSURL *url = [NSURL URLWithString: api_url];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
//    NSString * params =@"user_id=1&song_id=1&latitude=40&longitude=140";
    NSString * params = [NSString stringWithFormat:@"user_id=%i&song_id=%i&latitude=%f&longitude=%f", user_id, song_id, latitude, longitude];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask * task =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSString *msg = [NSString stringWithFormat:@"You have created a music host."];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                            message:msg delegate:self cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        if( error) {
            NSLog(@"error: %@", error);
        }
    }];
    [task resume];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
