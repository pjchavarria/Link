//
//  ViewController.m
//  LinkAlbum
//
//  Created by Paul Chavarria Podoliako on 2/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCellVideo.h"
#import "YoutubeAPIClient.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "EditorViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *allVideos;
@property (strong, nonatomic) NSMutableArray *searchingVideos;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// When filtering
@property (nonatomic) BOOL filtering;

@property (strong, nonatomic) NSString *nextPageToken;
@end

@implementation ViewController
BOOL fetchingVideos;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.allVideos = [NSMutableArray array];
    __block NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"youtubeAccessToken"];
    if (!accessToken) {
        [YoutubeAPIClient loginUserWithViewController:self];
    }else{
        NSString *refreshtoken = [[NSUserDefaults standardUserDefaults] objectForKey:@"youtubeRefreshToken"];
        
        if (!refreshtoken) {
            [self setAccessToken:accessToken];
        }else{
            [[YoutubeAPIClient client] refreshTokenSuccess:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"refreshtoken success");
                
                [self setAccessToken: responseObject[@"access_token"]];
                
                
                
            } error:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"refreshtokenerror %@",error);
            }];
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFeaturedVideos) name:@"loggedIntoYoutubeNotification" object:nil];
}

- (void)setAccessToken:(NSString *)accessToken
{
    [[YoutubeAPIClient client].requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [self getFeaturedVideos];
}

- (void)getFeaturedVideos
{
    fetchingVideos = YES;
    [[YoutubeAPIClient client] getFeatured:self.nextPageToken Videos:^(NSURLSessionDataTask *task, id responseObject) {
        [self.allVideos addObjectsFromArray:responseObject[@"items"]];
        self.nextPageToken = responseObject[@"nextPageToken"];
        [self.collectionView reloadData];
        fetchingVideos = NO;
    } error:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        fetchingVideos = NO;
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
    return (self.filtering)?self.searchingVideos.count:self.allVideos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"videoCell";
    
    
    CollectionViewCellVideo* cell = (CollectionViewCellVideo*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *data = self.allVideos[indexPath.row];
    
    
    cell.titleLabel.text = data[@"snippet"][@"localized"][@"title"];
    NSString *imageUrl= data[@"snippet"][@"thumbnails"][@"standard"][@"url"];
    
    if (!imageUrl) {
        imageUrl= data[@"snippet"][@"thumbnails"][@"high"][@"url"];
    }
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

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    NSLog(@"indexpath section %ld", (long)indexPath.section);
    if(kind == UICollectionElementKindSectionHeader){
    }
    if(kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView" forIndexPath:indexPath];
        view = footerview;
        [self getFeaturedVideos];
    }
    return view;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"pushEditor"] ){
        EditorViewController *controller = segue.destinationViewController;
        
        [controller initWithData:self.allVideos[((NSIndexPath *)sender).row]];
    }
}
@end
