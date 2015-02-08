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
             
             self.videoImage.image = [self drawFront:image text:combined atPoint:CGPointMake(30, self.videoImage.image.size.height-90)];
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
    
    image = [self drawFront:image text:self.textField.text atPoint:CGPointMake(30, self.videoImage.image.size.height-90)];
    image = [self imageByCombiningImage:image withImage:[UIImage imageNamed:@"livePaperLogo-20"]];
    
    NSMutableArray *activityItems = [NSMutableArray arrayWithObjects:@"title",image, nil];
    
    //you can have your own custom activities too:
    //NSArray *applicationActivities = @[[CustomActivity new],[OtherCustomActivity new]];
    UIActivityViewController *vc = [[UIActivityViewController alloc]initWithActivityItems:activityItems
                                                                    applicationActivities:nil];
    vc.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList,UIActivityTypeSaveToCameraRoll];
    
    
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

- (UIImage*)drawFront:(UIImage*)image text:(NSString*)text atPoint:(CGPoint)point
{
    UIFont *font = [UIFont systemFontOfSize:30.0f];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width-60, 80);
    [[UIColor whiteColor] set];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = NSMakeRange(0, [attString length]);
    
    [attString addAttribute:NSFontAttributeName value:font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];
    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(1.0f, 1.5f);
    [attString addAttribute:NSShadowAttributeName value:shadow range:range];
    
    [attString drawInRect:CGRectIntegral(rect)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (UIImage*)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    UIImage *image = nil;
    
    UIGraphicsBeginImageContextWithOptions(firstImage.size, NO, [[UIScreen mainScreen] scale]);
    
    [firstImage drawAtPoint:CGPointMake(0,0)];
    [secondImage drawAtPoint:CGPointMake(firstImage.size.width-30, 10)];
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
