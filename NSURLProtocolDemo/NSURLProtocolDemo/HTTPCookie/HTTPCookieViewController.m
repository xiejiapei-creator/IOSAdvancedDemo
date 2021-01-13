//
//  HTTPCookieViewController.m
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/18.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "HTTPCookieViewController.h"
#import <WebKit/WebKit.h>
#import "WKCookieManager.h"

@interface HTTPCookieViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation HTTPCookieViewController

#pragma mark - Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"沙盒路径：%@",NSHomeDirectory());
    
    [self createSubviews];
    [self saveCookie];
}

- (void)createSubviews
{
    self.navigationItem.title = @"HTTPCookie";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *webViewCookiesButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 100, 50)];
    webViewCookiesButton.backgroundColor = [UIColor blackColor];
    [webViewCookiesButton setTitle:@"WebViewCookies" forState:UIControlStateNormal];
    [webViewCookiesButton addTarget:self action:@selector(webViewCookies) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:webViewCookiesButton];
    
    UIButton *setWebViewCookiesButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 160, self.view.frame.size.width - 100, 50)];
    setWebViewCookiesButton.backgroundColor = [UIColor blackColor];
    [setWebViewCookiesButton setTitle:@"SetWebViewCookies" forState:UIControlStateNormal];
    [setWebViewCookiesButton addTarget:self action:@selector(setWebViewCookies) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setWebViewCookiesButton];
    
    UIButton *wkWebViewCookiesButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 220, self.view.frame.size.width - 100, 50)];
    wkWebViewCookiesButton.backgroundColor = [UIColor blackColor];
    [wkWebViewCookiesButton setTitle:@"WKWebViewCookies的坑" forState:UIControlStateNormal];
    [wkWebViewCookiesButton addTarget:self action:@selector(wkWebViewCookies) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wkWebViewCookiesButton];
    
    UIButton *PrintCookiesButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 280, self.view.frame.size.width - 100, 50)];
    PrintCookiesButton.backgroundColor = [UIColor blackColor];
    [PrintCookiesButton setTitle:@"打印HTTPCookieStorage的Cookies" forState:UIControlStateNormal];
    [PrintCookiesButton addTarget:self action:@selector(printCookies) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:PrintCookiesButton];
}

#pragma mark - Events

- (void)webViewCookies
{
    // 创建新的UIWebView
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 400, self.view.bounds.size.width, 600)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    // 打印出所有cookie信息
    NSHTTPCookieStorage *storages = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storages cookies])
    {
        NSLog(@"webViewCookies: %@",cookie);
    }
}

- (void)setWebViewCookies
{
    // 设置新Cookies
    [self setCookieWithDomain:@"http://www.baidu.com" sessionName:@"xiejiapei_token_UIWebView" sessionValue:@"55555555" expiresDate:nil];
    
    // 取出刚设置的新cookie
    NSArray *cookiesArray = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSDictionary *headerCookieDict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
    
    // 设置请求头
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    request.allHTTPHeaderFields = headerCookieDict;
    [self.webView loadRequest:request];
}

- (void)wkWebViewCookies
{
    // 创建新的WKWebView，该用configuration的初始化方式，为了向contoller中注入脚本
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *contoller = [[WKUserContentController alloc] init];
    [contoller addUserScript:[[WKCookieManager shareManager] futhureCookieScript]];
    configuration.userContentController = contoller;
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 400, self.view.bounds.size.width, 600) configuration:configuration];
    self.wkWebView.navigationDelegate = self;
    [self.view addSubview:self.wkWebView];

    // 将cookie放在请求头里面
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    NSArray  *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    // Cookies数组转换为requestHeaderFields
    NSDictionary *requestHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    // 设置请求头
    request.allHTTPHeaderFields = requestHeaderFields;
    NSLog(@"request.allHTTPHeaderFields: %@",request.allHTTPHeaderFields);
    [self.wkWebView loadRequest:request];
}

- (void)printCookies
{
    // 打印出所有cookie信息
    NSHTTPCookieStorage *storages = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storages cookies])
    {
        NSLog(@"打印出所有cookie信息: %@",cookie);
    }
}

// 在合适的时候（如登录成功）保存Cookie
- (void)saveCookie
{
    NSArray *allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in allCookies)
    {
        // 找到Custom_Client_Cookie
        if ([cookie.name isEqualToString:@"Custom_Client_Cookie"])
        {
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Custom_Client_Cookie"];
            if (dict)
            {
                // 本地Cookie有更新
                NSHTTPCookie *localCookie = [NSHTTPCookie cookieWithProperties:dict];
                if (![cookie.value isEqual:localCookie.value])
                {
                    NSLog(@"本地Cookie有更新");
                }
            }
            
            // 更新保存
            [[NSUserDefaults standardUserDefaults] setObject:cookie.properties forKey:@"Custom_Client_Cookie"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
    }
}

#pragma mark - WKNavigationDelegate

// 跳转新页面时候，可在此注入cookie
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"进入其他页面了");
    // 解决跳转页面Cookie丢失问题
    [[WKCookieManager shareManager] fixNewRequestCookieWithRequest:navigationAction.request];
    // 允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - Private Methods

// 设置新Cookies
- (void)setCookieWithDomain:(NSString*)domainValue
                sessionName:(NSString *)name
               sessionValue:(NSString *)value
                expiresDate:(NSDate *)date
{
    // 创建字典存储cookie的属性值
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    // 设置cookie名
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    // 设置cookie值
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    
    // 设置cookie域名
    NSURL *url = [NSURL URLWithString:domainValue];
    NSString *domain = [url host];
    [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
    
    // 设置cookie路径 一般写"/"
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    // 设置cookie版本, 默认写0
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    
    //设置cookie过期时间
    if (date)
    {
        [cookieProperties setObject:date forKey:NSHTTPCookieExpires];
    }
    else
    {
        // 推迟一年
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:([[NSDate date] timeIntervalSince1970] + 365*24*3600)];
        [cookieProperties setObject:date forKey:NSHTTPCookieExpires];
    }
    
    // 设置cookie的属性值到本地磁盘，因为手动设置的Cookie不会自动持久化到沙盒
    [[NSUserDefaults standardUserDefaults] setObject:cookieProperties forKey:@"app_cookies"];
    
    // 删除原cookie, 如果存在的话
    NSArray * arrayCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookice in arrayCookies)
    {
        // 清除特定某个cookie可以加个判断: if ([cookie.name isEqualToString:@"cookiename"])
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookice];
    }
    
    // 使用字典初始化新的cookie
    NSHTTPCookie *newcookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    
    // 使用cookie管理器 存储cookie
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newcookie];
}

@end
