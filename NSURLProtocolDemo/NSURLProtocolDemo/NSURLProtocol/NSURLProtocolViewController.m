//
//  NSURLProtocolViewController.m
//  NSURLProtocolDemo
//
//  Created by 谢佳培 on 2020/6/15.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "NSURLProtocolViewController.h"
#import "CustomURLProtocol.h"
#import <Masonry.h>
#import <AFNetworking.h>
#import <WebKit/WebKit.h>

@interface NSURLProtocolViewController ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *wk;

@property (nonatomic, strong) NSMutableData *data;

@end

@implementation NSURLProtocolViewController

#pragma mark - Life Circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSubviews];
    
    // 注册NSURLProtocol的子类
    // 当NSURLSeesionConfiguration使用protocolClasses注册的时候，此处不再起作用，可以直接注释掉
    // 当使用runtime拦截AFNetworking时，此处也需要注释掉，因为在自定义协议里已经配置过了
    [NSURLProtocol registerClass:[CustomURLProtocol class]];
    
    // 使用runtime拦截AFNetworking时，使用这句话
    // [CustomURLProtocol startMonitor];
}

- (void)createSubviews
{
    self.navigationItem.title = @"NSURLProtocol";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *webViewButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 100, 50)];
    webViewButton.backgroundColor = [UIColor blackColor];
    [webViewButton setTitle:@"WebViewDemo" forState:UIControlStateNormal];
    [webViewButton addTarget:self action:@selector(loadWebView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:webViewButton];
    
    UIButton *wkWebViewButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 160, self.view.frame.size.width - 100, 50)];
    wkWebViewButton.backgroundColor = [UIColor blackColor];
    [wkWebViewButton setTitle:@"WKWebViewDemo" forState:UIControlStateNormal];
    [wkWebViewButton addTarget:self action:@selector(loadWKWebView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wkWebViewButton];
    
    UIButton *URLSessionButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 220, self.view.frame.size.width - 100, 50)];
    URLSessionButton.backgroundColor = [UIColor blackColor];
    [URLSessionButton setTitle:@"NSURLSessionDemo" forState:UIControlStateNormal];
    [URLSessionButton addTarget:self action:@selector(loadNSURLSession) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:URLSessionButton];
    
    UIButton *AFNetworkingButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 280, self.view.frame.size.width - 100, 50)];
    AFNetworkingButton.backgroundColor = [UIColor blackColor];
    [AFNetworkingButton setTitle:@"AFNetworkingDemo" forState:UIControlStateNormal];
    [AFNetworkingButton addTarget:self action:@selector(loadAFNetworking) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:AFNetworkingButton];
    
    UIButton *AFNetworkingRuntimeButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 340, self.view.frame.size.width - 100, 50)];
    AFNetworkingRuntimeButton.backgroundColor = [UIColor blackColor];
    [AFNetworkingRuntimeButton setTitle:@"runtime加载AFNetworking" forState:UIControlStateNormal];
    [AFNetworkingRuntimeButton addTarget:self action:@selector(runtimeLoadAFNetworking) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:AFNetworkingRuntimeButton];
}

- (void)dealloc
{
    // 一经注册之后，所有交给URL Loading system的网络请求都会被拦截，所以当不需要拦截的时候，要进行注销
    // 当使用runtime拦截AFNetworking时，此处也需要注释掉，因为在自定义协议里已经配置过了
    [NSURLProtocol unregisterClass:[CustomURLProtocol class]];
    
    // 使用runtime拦截AFNetworking时，使用这句话
    // [CustomURLProtocol stopMonitor];
}

#pragma mark - Events

// 加载WebView
- (void)loadWebView
{
    // 移除旧的
    [self.webView removeFromSuperview];
    [self.wk removeFromSuperview];
    self.webView = nil;
    self.wk = nil;
    
    // 创建新的UIWebView
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, 600)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
}

// 加载WKWebView
- (void)loadWKWebView
{
    // 移除旧的
    [self.webView removeFromSuperview];
    [self.wk removeFromSuperview];
    self.webView = nil;
    self.wk = nil;
    
    // 创建新的WKWebView
    self.wk = [[WKWebView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, 600)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [self.wk loadRequest:request];
    [self.view addSubview:self.wk];
    
    //注册scheme
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    // cls 是否包含 sel方法
    if ([cls respondsToSelector:sel]) {
        // 通过http和https的请求，同理可通过其他的Scheme 但是要满足ULR Loading System
        [cls performSelector:sel withObject:@"http"];
        [cls performSelector:sel withObject:@"https"];
    }
}

// 加载NSURLSession
- (void)loadNSURLSession
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.protocolClasses = @[[CustomURLProtocol class]];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:mainQueue];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    NSLog(@"黑魔法视图控制器: 加载NSURLSession");
    [dataTask resume];
}

// 加载AFNetworking
- (void)loadAFNetworking
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 指定其protocolClasses
    // 将NSURLSessionConfiguration的属性protocolClasses的get方法hook掉，通过返回我们自己的protocol
    // 这样，我们就能够监控到通过sessionWithConfiguration:delegate:delegateQueue:得到的session的网络请求。
    configuration.protocolClasses = @[[CustomURLProtocol class]];
    
    // 不采用manager初始化，改为以下方式，可以配置Configuration
    //AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil sessionConfiguration:configuration];
    [manager GET:@"http://www.baidu.com" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject:%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
    }];
}

// runtime加载AFNetworking
- (void)runtimeLoadAFNetworking
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://www.baidu.com" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject:%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@",error);
    }];
}

#pragma mark - NSURLSessionDataDelegate

// 已经接收到响应时调用的代理方法
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    /* 当设置enableDebug = YES 的时候打开注释
    NSLog(@"黑魔法视图控制器:URL---%@, expectedContentLength----%lld",response.URL, response.expectedContentLength);
    completionHandler(NSURLSessionResponseAllow);
    _data = [[NSMutableData alloc] init];
     */
    
    // 当设置enableDebug = NO 的时候打开注释
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode == 200)
    {
        NSLog(@"黑魔法视图控制器: 请求成功");
        NSLog(@"黑魔法视图控制器: 响应头 %@", httpResponse.allHeaderFields);// 响应头
        
        // 初始化接收数据的NSData变量
        _data = [[NSMutableData alloc] init];
        
        //执行Block回调 来继续接收响应体数据
        //执行completionHandler 用于使网络连接继续接受数据
        completionHandler(NSURLSessionResponseAllow);
    }
    else
    {
        NSLog(@"请求失败");
    }
}



// 接收到数据包时调用的代理方法
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"黑魔法视图控制器: 收到了一个数据包 data == %@，接受到了%li字节的数据",data,data.length);
    
    //拼接完整数据
    [_data appendData:data];
    // 当设置enableDebug = NO 的时候打开注释
    // NSString *dataStr = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"黑魔法视图控制器: 拼接完后为 %@", _data);
}

// 数据接收完毕时调用的代理方法
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"黑魔法视图控制器: 数据接收完成");
    
    if (error)
    {
        NSLog(@"数据接收出错!");
        _data = nil;// 清空出错的数据
    }
    else
    {
        //数据传输成功无误，JSON解析数据
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"黑魔法视图控制器: 数据传输成功无误，JSON解析数据后 %@", dic);
    }
}

@end
