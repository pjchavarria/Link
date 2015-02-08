//
//  EditorViewController.m
//  LinkAlbum
//
//  Created by Paul Chavarria Podoliako on 2/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "EditorViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CustomActivityItemProvider.h"
#import "XCDYouTubeKit.h"
#import "HeliosAPIClient.h"

@interface EditorViewController ()

@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property (weak, nonatomic) IBOutlet UIImageView *videoImage;
@property (weak, nonatomic) IBOutlet UIImageView *footerImage;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

- (IBAction)pressedPrint:(id)sender;
- (IBAction)playVideo:(id)sender;

@end

@implementation EditorViewController

- (void)initWithData:(NSDictionary *)data
{
    self.data = data;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *image = self.data[@"snippet"][@"thumbnails"];
    [self.videoImage sd_setImageWithURL:[NSURL URLWithString: image[[image.allKeys containsObject:@"highres"]?@"highres":@"standard"][@"url"]]];
    
    self.title = self.data[@"snippet"][@"localized"][@"title"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *combined;
    if (string.length == 0 && textField.text.length >= 1) {
        combined = [textField.text substringToIndex:textField.text.length-1];
    }else{
        combined = [textField.text stringByAppendingString:string];
    }
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    
    NSDictionary *image = self.data[@"snippet"][@"thumbnails"];
    NSURL *url = [NSURL URLWithString: image[[image.allKeys containsObject:@"highres"]?@"highres":@"standard"][@"url"]];
    
    [manager downloadWithURL:url
                     options:0
                    progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             // do something with image
             self.videoImage.image = image;
             
             self.footerImage.image = [self drawFront:[UIImage imageNamed:@"white"] text:combined size:20.0f atPoint:CGPointMake(120,10)];
         }
     }];
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    return YES;
}



- (IBAction)pressedPrint:(id)sender {
    
    NSLog(@"working..");

    //NSData *imageData = UIImageJPEGRepresentation(self.videoImage.image, 1.0);
    NSDictionary *image = self.data[@"snippet"][@"thumbnails"];
    NSString *imageURL = image[[image.allKeys containsObject:@"highres"]?@"highres":@"standard"][@"url"];
    
    [[HeliosAPIClient client] postWithParameters:@{@"youtube_url":[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",self.data[@"id"]],@"image_url":imageURL} success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:responseObject[@"url"]]];
        
        NSString *authValue = [NSString stringWithFormat:@"%@",responseObject[@"token"]];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse * response,
                                                   NSData * data,
                                                   NSError * error) {
                                   if (!error){
                                       UIImage *image = [UIImage imageWithData:data];
                                       
                                       [self showActivityProviderWithImage:image];
                                   } else {
                                       NSLog(@"ERRORE: %@", error);
                                   }
                                   
                               }];
        
    } error:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
    

}

- (void)showActivityProviderWithImage:(UIImage *)image
{
    
    self.footerImage.image = [self drawFront:[UIImage imageNamed:@"white"] text:self.textField.text size:30.0f atPoint:CGPointMake(120, 10)];
    image = [self imageByCombiningImage:image withImage:self.footerImage.image secondImagePoint:CGPointMake(0, image.size.height) sumSizes:YES];
    image = [self imageByCombiningImage:image withImage:[UIImage imageNamed:@"livePaperLogo-20"] secondImagePoint:CGPointMake(image.size.width-30, 10) sumSizes:NO];
    
    NSMutableArray *activityItems = [NSMutableArray arrayWithObjects:@"title",image, nil];
    
    //you can have your own custom activities too:
    //NSArray *applicationActivities = @[[CustomActivity new],[OtherCustomActivity new]];
    UIActivityViewController *vc = [[UIActivityViewController alloc]initWithActivityItems:activityItems
                                                                    applicationActivities:nil];
    vc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList];
    
    
    //-- define the activity view completion handler
    vc.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        
        if (completed) {
            
        } else {
            if (activityType == NULL) {
                NSLog(@"User dismissed the view controller without making a selection.");
            } else {
                NSLog(@"Activity was not performed.");
            }
        }
    };
    
    
    
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (UIImage*)drawFront:(UIImage*)image text:(NSString*)text size:(CGFloat)size atPoint:(CGPoint)point
{
    UIFont *font = [UIFont fontWithName:@"Noteworthy-Light" size:size];
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);

    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width-40, 80);
    [[UIColor whiteColor] set];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = NSMakeRange(0, [attString length]);
    
    [attString addAttribute:NSFontAttributeName value:font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    
    
    [attString drawInRect:CGRectIntegral(rect)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage secondImagePoint:(CGPoint)position sumSizes:(BOOL)sum {
    UIImage *image = nil;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(firstImage.size.width, (sum)?firstImage.size.height+secondImage.size.height+200: firstImage.size.height) , NO, [[UIScreen mainScreen] scale]);
    
    [firstImage drawAtPoint:CGPointMake(0,0)];
    [secondImage drawAtPoint:position];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction)playVideo:(id)sender {
    
    NSString *videoIdentifier = self.data[@"id"];
    if (!videoIdentifier || [videoIdentifier isEqualToString:@""]) {
        return;
    };
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoIdentifier];

    [self presentMoviePlayerViewControllerAnimated:self.videoPlayerViewController];
}

@end
