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
//    self.songs = @[@"A song1", @"A song2", @"A song3", @"A song4", @"Blue1", @"Blue2", @"Blue3", @"Cat1", @"Cat2", @"Cat3", @"Song 1", @"Song 2", @"Song 3", @"Song 4", @"Music1", @"Music2", @"Music3", @"Music4", @"Music5"];
    self.songs = @[@"Camel", @"Cockatoo", @"Dog", @"Donkey", @"Emu", @"Giraffe", @"Greater Rhea", @"Hippopotamus", @"Horse", @"Koala", @"Lion", @"Llama", @"Manatus", @"Meerkat", @"Panda", @"Peacock", @"Pig", @"Platypus", @"Polar Bear", @"Rhinoceros", @"Seagull", @"Tasmania Devil", @"Whale", @"Whale Shark", @"Wombat", @"Buffalo", @"Bear", @"Black Swan"];
    _songs = [_songs sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    _songsDict = [NSMutableDictionary new];
    
    for (NSString *str in _songs) {
        NSString *key = [[str substringToIndex:1] capitalizedString];
        NSMutableArray *arr;
        if([_songsDict objectForKey:key]){
            arr = [_songsDict objectForKey:key];
        } else {
            arr = [NSMutableArray new];
        }
        [arr addObject:str];
//        NSLog(@"%@ %i",key, [arr count]);
        [_songsDict setObject:arr forKey:key];
    }
    
    _songSectionTitles = [[_songsDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    _selectedRow = -1;
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
    NSString *songName = [sectionSongs objectAtIndex:indexPath.row];
    cell.textLabel.text = songName;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *sectionTitle = [_songSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionSongs = [_songsDict objectForKey:sectionTitle];
    NSString *songName = [sectionSongs objectAtIndex:indexPath.row];
    NSString *msg = [NSString stringWithFormat:@"Do you really want to use \"%@\" to create your host?", songName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose this song"
                                                    message:msg delegate:self cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    alert.tag = 0;
    [alert show];

    [tableView cellForRowAtIndexPath:indexPath].selected = false;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Is this my Alert View?
    if (alertView.tag == 0) {
        if (buttonIndex == 0) {// Cancel Button
//            [self submitData];
            
        }
        else if (buttonIndex == 1) {// OK Button
            
        }
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
