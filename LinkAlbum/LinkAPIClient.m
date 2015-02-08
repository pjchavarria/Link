//
//  YoutubeAPIClient.m
//  LinkAlbum
//
//  Created by Paul Chavarria Podoliako on 2/7/15.
//  Copyright (c) 2015 AnyTap. All rights reserved.
//

#import "LinkAPIClient.h"
#import "SVWebViewController.h"
#import "AppDelegate.h"

static NSString * const kLinkBaseURL = @"https://www.livepaperapi.com/api/v1";



@implementation LinkAPIClient

+ (instancetype)client {
    static LinkAPIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[LinkAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kLinkBaseURL]];
    });
    
    return sharedClient;
}


- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
//        self.responseSerializer = [AFJSONResponseSerializer serializer];
//        self.requestSerializer = [AFJSONRequestSerializer serializer];
        //[self.requestSerializer setValue:kYoutubeClientID forHTTPHeaderField:@"client_id"];
        
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [self.requestSerializer setValue:@"Basic aGxncjI0NGs1cmVxdXpmeWI5dmtucDZ3eTVhZnVnOGM6M29CQjRnMjhLVGM4VTRQNHJZQlhpODRhTkZMRjc2eFI=" forHTTPHeaderField:@"Authorization"];
        
        
        
    }
    
    return self;
}



- (void)tokenWithRequest:(HTTPSuccess)success error:(HTTPError)error
{
    
    NSDictionary *parameters = @{@"scope":@"default",
                                 @"grant_type":@"client_credentials"};
    
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:@"https://www.livepaperapi.com/auth/v1/token" parameters:parameters error:&serializationError];
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


- (void)postTriggersWithParameters:(NSDictionary *)parameters success:(HTTPSuccess)success error:(HTTPError)error
{
    
    NSString *path = [NSString stringWithFormat:@"triggers"];
    [self POST:path parameters:parameters success:success failure:error];
}

- (void)postUploadImageData:(NSData *)data success:(HTTPSuccess)success error:(HTTPError)error
{
    NSDictionary *parameters = @{@"scope":@"default",
                                 @"grant_type":@"client_credentials"};
    
    [self.requestSerializer setValue:@"image/jpeg" forHTTPHeaderField:@"Content-type"];
    
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:@"https://storage.livepaperapi.com/objects/v1/files" parameters:parameters error:&serializationError];
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

@end
