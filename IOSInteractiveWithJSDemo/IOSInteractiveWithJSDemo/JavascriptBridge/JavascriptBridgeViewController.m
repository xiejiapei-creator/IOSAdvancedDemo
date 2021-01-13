//
//  JavascriptBridgeViewController.m
//  IOSInteractiveWithJSDemo
//
//  Created by 谢佳培 on 2020/6/12.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "JavascriptBridgeViewController.h"
#import <WebKit/WebKit.h>
#import <WebViewJavascriptBridge.h>

@interface JavascriptBridgeViewController ()<WKUIDelegate>

@property (strong, nonatomic) WKWebView *wkWebView;
@property (strong, nonatomic) WebViewJavascriptBridge *webViewJavascriptBridge;

@end

@implementation JavascriptBridgeViewController

#pragma mark - Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OC调用JS中的方法" style:UIBarButtonItemStylePlain target:self action:@selector(didClickRightItemAction)];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [self wkwebViewScalPreferences];
    
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
    self.wkWebView.UIDelegate = self;
    [self.view addSubview:self.wkWebView];
    
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"JavascriptBridge.html" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.wkWebView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    
    // 传入wkWebView来初始化webViewJavascriptBridge，框架会自动判断传入的是WKWebView还是UIWebView作出处理
    self.webViewJavascriptBridge = [WebViewJavascriptBridge bridgeForWebView:self.wkWebView];
    
    // 如果你要在VC中实现 UIWebView的代理方法 就实现下面的代码(否则省略)
    // [self.webViewJavascriptBridge setWebViewDelegate:self];
    
    // JS调用OC中的方法
    [self.webViewJavascriptBridge registerHandler:@"jsCallsOC" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 自动切换到主线程让我们拿到数据后更新UI
        NSLog(@"currentThread == %@",[NSThread currentThread]);
        
        // `data`是JS回传给我们的该方法会用到的实际数据
        // responseCallback是调用完OC之后的回调
        NSLog(@"data == %@ ，调用完OC后的回调： %@",data,responseCallback);
    }];
}

#pragma mark - Events

- (void)didClickRightItemAction
{
    // 如果不需要参数，不需要回调，使用这个
//    [self.webViewJavascriptBridge callHandler:@"OCCallJSFunction"];
    // 如果需要参数，不需要回调，使用这个
//    [self.webViewJavascriptBridge callHandler:@"OCCallJSFunction" data:@"今天天气要下雨了吧，我看外面在打雷"];
    // 如果既需要参数，又需要回调，使用这个
    [self.webViewJavascriptBridge callHandler:@"OCCallJSFunction" data:@"今天天气要下雨了吧，我看外面在打雷" responseCallback:^(id responseData) {
        NSLog(@"currentThread == %@",[NSThread currentThread]);
        NSLog(@"调用完JS后的回调：%@",responseData);
    }];
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private Methods

// 调整按钮大小适应APP页面
- (WKUserContentController *)wkwebViewScalPreferences
{
    // js注入: json调整按钮大小脚本
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    /** WKUserScript就是帮助我们完成JS注入的类，它能帮助我们在页面填充前或js填充完成后调用
     * 参数1:脚本的源代码
     * 参数2:脚本应注入网页的时间，是个枚举,End表示：在文档完成加载之后，但在其他子资源完成加载之前插入脚本
     * 参数3:是否加入所有框架，还是只加入主框架
     */
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUserContentController = [[WKUserContentController alloc] init];
    [wkUserContentController addUserScript:wkUserScript];
    
    return wkUserContentController;
}
@end
