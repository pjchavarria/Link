//
//  ViewController.m
//  LinkAlbum
//
//  Created by Paul Chavarria Podoliako on 2/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "MyViewController.h"
#import "CollectionViewCellVideo.h"
#import "YoutubeAPIClient.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "EditorViewController.h"

@interface MyViewController ()
@property (strong, nonatomic) NSMutableArray *allVideos;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// When filtering
@property (nonatomic) BOOL filtering;
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMyVideos) name:@"loggedIntoYoutubeNotification" object:nil];
}

- (void)getMyVideos
{
    [[YoutubeAPIClient client] getMyVideos:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
        self.allVideos = responseObject[@"items"];
        [self.collectionView reloadData];
        
    } error:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.allVideos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"videoCell";
    
    
    CollectionViewCellVideo* cell = (CollectionViewCellVideo*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *data = self.allVideos[indexPath.row];
    
    
    cell.titleLabel.text = data[@"snippet"][@"localized"][@"title"];
    NSString *imageUrl= data[@"snippet"][@"thumbnails"][@"standard"][@"url"];
    [cell.videoImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageUrl]]];
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.bounds.size.width - (8*2), 90);
}

#pragma mark UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // go to video editor or somehting
    [self performSegueWithIdentifier:@"pushEditor" sender:indexPath];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"pushEditor"] ){
        EditorViewController *controller = segue.destinationViewController;
        
        [controller initWithData:self.allVideos[((NSIndexPath *)sender).row]];
    }
}
@end
