//
//  UseWKWebViewViewController.m
//  IOSInteractiveWithJSDemo
//
//  Created by 谢佳培 on 2020/10/12.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "UseWKWebViewViewController.h"

@interface UseWKWebViewViewController ()

@end

@implementation UseWKWebViewViewController

// WebView不仅可以加载HTML页面，还支持pdf、word、txt、各种图片等等的显示
- (void)createWebView
{
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"WKWebView" ofType:@"html"];
    
    // 加载HTML页面
    NSError *error = nil;
    NSString *html = [[NSString alloc] initWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&error];
    NSURL *baseURL = [NSURL URLWithString:@"https://"];
    [self.webView loadHTMLString:html baseURL:baseURL];
    
    // Data
    NSData *htmlData = [[NSData alloc] initWithContentsOfFile:htmlPath];
    [self.webView loadData:htmlData MIMEType:@"text/html" characterEncodingName:@"UTF-8" baseURL:baseURL];
    
    // Request
    NSURL *url = [NSURL URLWithString:@""];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    // 加载本地文件
    NSURL *localURL = [NSURL fileURLWithPath:@""];
    [_webView loadFileURL:localURL allowingReadAccessToURL:url];
        
    [_webView reload];// 刷新
    [_webView stopLoading];// 停止加载
    [_webView goBack];// 后退函数
    [_webView goForward];// 前进函数
    [_webView canGoBack];// 是否可以后退
    [_webView canGoForward];// 向前
    [_webView isLoading];// 是否正在加载
    _webView.allowsBackForwardNavigationGestures = YES;// 允许左右划手势导航
    
    self.webView.navigationDelegate = self;
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *urlString = [[navigationAction.request URL] absoluteString];
    urlString = [urlString stringByRemovingPercentEncoding];
    
    // 用://截取字符串
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
    if (urlComps.count > 0)
    {
        // 获取协议头
        NSString *protocolHead = [urlComps objectAtIndex:0];
        NSLog(@"protocolHead = %@",protocolHead);
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 协议-开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"开始加载");
}

// 协议-当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"内容开始返回");
}

// 协议-加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"加载完成");
}

// 协议-加载失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"加载失败 error :  %@", error.localizedDescription);
}

@end
