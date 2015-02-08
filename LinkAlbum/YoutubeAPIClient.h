//
//  YoutubeAPIClient.h
//  LinkAlbum
//
//  Created by Paul Chavarria Podoliako on 2/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void (^HTTPSuccess)(NSURLSessionDataTask *task, id responseObject);
typedef void (^HTTPError)(NSURLSessionDataTask *task, NSError *error);

@interface YoutubeAPIClient : AFHTTPSessionManager

+ (instancetype)client;

+ (void)loginUserWithViewController:(UIViewController *)controller;

- (void)tokenWithCode:(NSString *)code success:(HTTPSuccess)success error:(HTTPError)error;
- (void)refreshTokenSuccess:(HTTPSuccess)success error:(HTTPError)error;

- (void)getFeatured:(NSString *)pageToken Videos:(HTTPSuccess)success error:(HTTPError)error;
- (void)getMyVideos:(HTTPSuccess)success error:(HTTPError)error;
@end
