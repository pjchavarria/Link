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

@interface LinkAPIClient : AFHTTPSessionManager

+ (instancetype)client;

- (void)tokenWithRequest:(HTTPSuccess)success error:(HTTPError)error;
- (void)postTriggersWithParameters:(NSDictionary *)parameters success:(HTTPSuccess)success error:(HTTPError)error;
- (void)postUploadImageData:(NSData *)data success:(HTTPSuccess)success error:(HTTPError)error;
@end
