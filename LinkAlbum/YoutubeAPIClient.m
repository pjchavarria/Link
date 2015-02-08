//
//  YoutubeAPIClient.m
//  LinkAlbum
//
//  Created by Paul Chavarria Podoliako on 2/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "YoutubeAPIClient.h"
#import "SVWebViewController.h"
#import "AppDelegate.h"

static NSString * const kYoutubeBaseURL = @"https://www.googleapis.com/youtube/v3";
static NSString * const kYoutubeClientID = @"957173306117-dgrbl3j090jva6mo210a9ep7iiono06u.apps.googleusercontent.com";
static NSString * const kYoutubeClientSecret = @"QVy5iqbFdj89F7Nmlaqd5ygs";

static NSString * const kYoutubeOauth = @"https://accounts.google.com/o/oauth2/auth";


@implementation YoutubeAPIClient

+ (instancetype)client {
    static YoutubeAPIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[YoutubeAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kYoutubeBaseURL]];
    });
    
    return sharedClient;
}


- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
//        self.responseSerializer = [AFJSONResponseSerializer serializer];
//        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.requestSerializer setValue:kYoutubeClientID forHTTPHeaderField:@"client_id"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        
    }
    
    return self;
}

+ (void)loginUserWithViewController:(UIViewController *)controller
{
    NSString *authorizationURL = @"https://accounts.google.com/o/oauth2/auth?client_id=957173306117-dgrbl3j090jva6mo210a9ep7iiono06u.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost&scope=https://www.googleapis.com/auth/youtube&response_type=code&access_type=offline";
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:authorizationURL];
    webViewController.webViewController.webView.delegate = (UIResponder<UIWebViewDelegate> *)[UIApplication sharedApplication].delegate;
    ((AppDelegate *)[UIApplication sharedApplication].delegate).controller = webViewController;
    [controller presentViewController:webViewController animated:YES completion:NULL];
}

- (void)tokenWithCode:(NSString *)code success:(HTTPSuccess)success error:(HTTPError)error
{
    
    NSDictionary *parameters = @{@"code":code,
                                 @"client_id":kYoutubeClientID,
                                 @"client_secret":kYoutubeClientSecret,
                                 @"redirect_uri":@"http://localhost",
                                 @"grant_type":@"authorization_code"};
    
    
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    
    //[self POST:path parameters:parameters success:success failure:error];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:@"https://accounts.google.com/o/oauth2/token" parameters:parameters error:&serializationError];
    if (serializationError) {
        if (error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                error(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
    
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (error) {
                //error(dataTask, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    [dataTask resume];
}
- (void)refreshTokenSuccess:(HTTPSuccess)success error:(HTTPError)error
{
    NSDictionary *parameters = @{@"refresh_token":[[NSUserDefaults standardUserDefaults] objectForKey:@"youtubeRefreshToken"],
                                 @"client_id":kYoutubeClientID,
                                 @"client_secret":kYoutubeClientSecret,
                                 @"grant_type":@"refresh_token"};
    
    
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:@"https://accounts.google.com/o/oauth2/token" parameters:parameters error:&serializationError];
    if (serializationError) {
        if (error) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                error(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if (error) {
            if (error) {
                //error(dataTask, error);
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    
    [dataTask resume];
}


- (void)getFeatured:(NSString *)pageToken Videos:(HTTPSuccess)success error:(HTTPError)error
{
    NSString *path = [NSString stringWithFormat:@"videos"];
    if (pageToken) {
        [self GET:path parameters:@{@"part":@"snippet",@"chart":@"mostPopular",@"maxResults":@"20",@"pageToken":pageToken} success:success failure:error];
    }else{
        [self GET:path parameters:@{@"part":@"snippet",@"chart":@"mostPopular",@"maxResults":@"20"} success:success failure:error];
    }
    
}

- (void)getMyVideos:(HTTPSuccess)success error:(HTTPError)error
{
    NSString *path = [NSString stringWithFormat:@"videos"];
    [self GET:path parameters:@{@"part":@"snippet",@"myRating":@"like",@"maxResults":@"20"} success:success failure:error];
}

@end
