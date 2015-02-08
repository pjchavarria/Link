//
//  YoutubeAPIClient.m
//  LinkAlbum
//
//  Created by Paul Chavarria Podoliako on 2/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "HeliosAPIClient.h"
#import "SVWebViewController.h"
#import "AppDelegate.h"

static NSString * const kHeliosBaseURL = @"http://ylink.15.126.207.64.xip.io";

@implementation HeliosAPIClient

+ (instancetype)client {
    static HeliosAPIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[HeliosAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kHeliosBaseURL]];
    });
    
    return sharedClient;
}


- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
//        self.responseSerializer = [AFJSONResponseSerializer serializer];
//        self.requestSerializer = [AFJSONRequestSerializer serializer];
        
        self.responseSerializer.acceptableContentTypes = [self.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    }
    
    return self;
}



- (void)postWithParameters:(NSDictionary *)parameters success:(HTTPSuccess)success error:(HTTPError)error
{
    
    NSString *path = [NSString stringWithFormat:@"ylink"];
    [self POST:path parameters:parameters success:success failure:error];
}


@end
