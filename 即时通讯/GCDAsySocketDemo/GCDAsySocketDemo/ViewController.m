//
//  ViewController.m
//  GCDAsySocketDemo
//
//  Created by 谢佳培 on 2021/2/25.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *contentTF;
@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation ViewController

#pragma mark - 点击按钮触发的事件

// 连接socket
- (IBAction)didClickConnectSocket:(id)sender
{
    // 创建socket
    if (self.socket == nil)
    {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    
    // 连接socket
    if (!self.socket.isConnected)
    {
        NSError *error;
        [self.socket connectToHost:@"127.0.0.1" onPort:8090 withTimeout:-1 error:&error];
        if (error) NSLog(@"错误信息：%@",error);
    }
}

// 发送消息
- (IBAction)didClickSendAction:(id)sender
{
    NSData *data = [self.contentTF.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:-1 tag:10086];
}

// 关闭socket
- (IBAction)didClickCloseAction:(id)sender
{
    [self.socket disconnect];
    self.socket = nil;
}

// 重连socket
- (IBAction)didClickReconnectAction:(id)sender
{
    // 创建socket
    if (self.socket == nil)
    {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
        
    // 连接socket
    if (!self.socket.isConnected)
    {
        NSError *error;
        [self.socket connectToHost:@"127.0.0.1" onPort:8090 withTimeout:-1 error:&error];
        if (error) NSLog(@"错误信息：%@",error);
    }
}

#pragma mark - GCDAsyncSocketDelegate

// 已经连接到服务器
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(nonnull NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功，主机：%@，端口：%d",host,port);
    // -1 表示长链接，保持链接状态
    [self.socket readDataWithTimeout:-1 tag:10086];
}

// 断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开socket连接，错误原因：%@",err);
}

// 已经接收到服务器返回来的数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到tag = %ld，长度 = %ld 的数据",tag,data.length);
    [self.socket readDataWithTimeout:-1 tag:10086];
}

// 成功向服务器发送消息
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"%ld 成功向服务器发送消息",tag);
}

@end
