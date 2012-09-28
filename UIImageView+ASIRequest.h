//
//  UIImageView+ASIRequest.h
//  
//
//  Created by 02 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
@interface UIImageView (ASIRequest)

- (void)loadImageFromURL:(NSString*)urlString;
- (void)requestImageFailed:(ASIHTTPRequest*)request;
@end
