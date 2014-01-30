//
//  AboutViewController.h
//  jaigiro
//
//  Created by Sergio Garcia on 13/01/14.
//  Copyright (c) 2014 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(strong, nonatomic) NSString *fileName;

@end
