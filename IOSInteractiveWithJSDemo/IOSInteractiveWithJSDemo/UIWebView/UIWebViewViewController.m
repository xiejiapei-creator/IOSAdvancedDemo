//
//  UIWebViewViewController.m
//  3-JavaScriptCoreDemo
//
//  Created by 谢佳培 on 2020/6/12.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "UIWebViewViewController.h"

@interface UIWebViewViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation UIWebViewViewController

#pragma mark - Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OC调用showAlert" style:UIBarButtonItemStylePlain target:self action:@selector(didClickRightItemAction)];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"UIWebView.html" withExtension:nil];;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - Events

- (void)didClickRightItemAction
{
    // OC 调用 JS中的弹框方法
    NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:@"showAlert('HELLO')()"];
    NSLog(@"result == %@",result);
}

#pragma mark - UIWebViewDelegate

// 该方法会加载所有请求数据，以及控制是否加载
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@",request.URL.scheme); // 标识
    NSLog(@"%@",request.URL.host);   // 方法名
    NSLog(@"%@",request.URL.pathComponents);  // 参数
    
    // 拦截URL
    if ([request.URL.scheme isEqualToString:@"tzedu"])
    {
        // JS 调用 OC
        NSArray *args = request.URL.pathComponents;
        NSString *methodName = args[1];
        // args[1] = JSCallOC:  args[2] = hello word
        if ([methodName isEqualToString:@"JSCallOC:"])
        {
            [self JSCallOC:args[2]];
        }
        return NO;
    }
    return YES;
}

// 加载完成
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *titlt = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = titlt;
}

#pragma mark - Private Methods

- (void)JSCallOC:(NSString *)str
{
    // 打印结果为：这是一个OC中的方法，被JS调用了:hello word
    NSLog(@"这是一个OC中的方法，被JS调用了:%@",str);
}

@end
