//
//  UseWKWebViewViewController.h
//  IOSInteractiveWithJSDemo
//
//  Created by 谢佳培 on 2020/10/12.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UseWKWebViewViewController : UIViewController <WKUIDelegate, WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;

@end

NS_ASSUME_NONNULL_END
