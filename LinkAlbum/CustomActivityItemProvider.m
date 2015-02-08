//
//  CustomActivityItemProvider.m
//  Trakr
//
//  Created by Paul on 8/4/14.
//  Copyright (c) 2014 EverFox. All rights reserved.
//

#import "CustomActivityItemProvider.h"
@interface CustomActivityItemProvider()
@property (nonatomic, strong) NSString *text;
@end
@implementation CustomActivityItemProvider
- (id)initWithText:(NSString *)text{
    
    if ((self = [super initWithPlaceholderItem:text])) {
        self.text = text ?: @"";
    }
    return self;
}

//- (id)item {
//    NSString *activityType = self.activityType;
//    if ([self.placeholderItem isKindOfClass:[NSString class]]) {
//        if ([self.activityType isEqualToString:UIActivityTypePostToFacebook]) {
//            
//            return @[[NSString stringWithFormat:@"%@ via AnimeTrakr", self.text],self.image];
//            
//        } else if ([activityType isEqualToString:UIActivityTypePostToTwitter] ||
//                   [self.activityType isEqualToString:UIActivityTypeMail] ||
//                   [activityType isEqualToString:UIActivityTypeMessage]) {
//            return @[[NSString stringWithFormat:@"%@ via @AnimeTrakr", self.text],self.image];
//        }
//    }
//    
//    return self.placeholderItem;
//}
- (id)item
{
    //Generates and returns the actual data object
    return @"";
}
//
//// The following are two methods in the UIActivityItemSource Protocol
//// (UIActivityItemProvider conforms to this protocol) - both methods required
//
////- Returns the data object to be acted upon. (required)
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return [NSString stringWithFormat:@"%@", self.text];
    }
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter] ||
        [activityType isEqualToString:UIActivityTypePostToWeibo] ||
        [activityType isEqualToString:UIActivityTypeMail]) {
        return [NSString stringWithFormat:@"%@", self.text];
    }
    
    return self.text;
}
@end
