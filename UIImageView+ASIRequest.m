//
//  UIImageView+ASIRequest.m
//  
//
//  Created by 02 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//



#define defaultImage @"icon.png"

#import "UIImageView+ASIRequest.h"

@implementation UIImageView (ASIRequest)

- (void)loadImageFromURL:(NSString*)urlString{
    
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [aiView setFrame:CGRectMake(0, 0, 32, 32)];
    [aiView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [self addSubview:aiView];
    [aiView startAnimating];
    [aiView release];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults]objectForKey:@"cachedImages"];
    
    NSString *path = [dict objectForKey:[url absoluteString]];
    
    if (path&&[[NSFileManager defaultManager]fileExistsAtPath:path]) {
        [self setImage:[UIImage imageWithContentsOfFile:path]];
        [aiView removeFromSuperview];
        return;
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachesDirectory = [paths objectAtIndex:0];
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@", (NSString *)uuidString];
    CFRelease(uuidString);
    
    NSString *saveDir = [cachesDirectory stringByAppendingPathComponent:uniqueFileName];
    
//    NSLog(saveDir);
    
    [request setDownloadDestinationPath:saveDir];
    [request setDelegate:[self retain]];
    [request setTimeOutSeconds:25];
    [request setDidFailSelector:@selector(requestImageFailed:)];
    [request setDidFinishSelector:@selector(requestImageSuc:)];
    [request startAsynchronous];

}

- (void)requestImageSuc:(ASIHTTPRequest*)request{
//    NSLog(@"1111 %@",[request downloadDestinationPath]);
    
    for (id subview in [self subviews]) {
        if ([subview isKindOfClass:[UIActivityIndicatorView class]]) {
            [subview removeFromSuperview];
            break;
        }
    }

    
    if ([[NSFileManager defaultManager]fileExistsAtPath:[request downloadDestinationPath]]) {
        UIImage *image = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
        if (image) {
            [self setImage:image];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            NSDictionary *oldDict = [[NSUserDefaults standardUserDefaults]objectForKey:@"cachedImages"];
            if (oldDict) {
                [dict addEntriesFromDictionary:oldDict];
            }
            [dict setObject:[request downloadDestinationPath] forKey:[[request url]absoluteString]];
            [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"cachedImages"];
            [dict release];
            
            [self release];
        }else{
            [self requestImageFailed:request];
        }
    }else{
        [self requestImageFailed:request];
    }
    
//    NSLog(@"suc %i",[self retainCount]);
    
    
//    [request release];
}

- (void)requestImageFailed:(ASIHTTPRequest*)request{
    for (id subview in [self subviews]) {
        if ([subview isKindOfClass:[UIActivityIndicatorView class]]) {
            [subview removeFromSuperview];
            break;
        }
    }
    
    [self setImage:[UIImage imageNamed:@"icon.png"]];
    
//    NSLog(@"fail %i",[self retainCount]);
    
    [self release];
//    [request release];
}


@end
