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

@interface HeliosAPIClient : AFHTTPSessionManager

+ (instancetype)client;

- (void)postWithParameters:(NSDictionary *)parameters success:(HTTPSuccess)success error:(HTTPError)error;
@end
