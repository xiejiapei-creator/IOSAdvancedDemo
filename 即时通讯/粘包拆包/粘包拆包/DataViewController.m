//
//  DataViewController.m
//  粘包拆包
//
//  Created by 谢佳培 on 2021/2/25.
//

#import "DataViewController.h"
#import <GCDAsyncSocket.h>

// 数据类型
#define kcTextDataType 0x00000000
#define kcImageDataType 0x00000001
#define kcVideoDataType 0x00000002

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface DataViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSTimer *heartTimer;// 心跳timer
@property (nonatomic, assign) NSInteger reconnectTime;// 重连等待时间

@end

@implementation DataViewController

#pragma mark - 点击按钮

// 链接socket
- (IBAction)didClickConnectSocket:(UIButton *)sender
{
    [self connectSocketOrCreate];
}

// 发送文本
- (IBAction)didClickSendTextAction:(UIButton *)sender
{
    NSData *data = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned int command = kcTextDataType;
    [self sendData:data dataType:command];
}

// 发送图片
- (IBAction)didClickSendImageAction:(UIButton *)sender
{
    UIImage *image = [UIImage imageNamed:@"luckcoffee"];
    NSData  *imageData  = UIImagePNGRepresentation(image);

    unsigned int command = kcImageDataType;
    [self sendData:imageData dataType:command];
}

// 发送视频
- (IBAction)didClickSendVideoAction:(UIButton *)sender
{
    NSData  *videoData  = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"girl.mp4" ofType:nil]];
    
    unsigned int command = kcVideoDataType;
    [self sendData:videoData dataType:command];
}

#pragma mark - 发送数据格式化

- (void)sendData:(NSData *)data dataType:(unsigned int)dataType
{
    NSMutableData *mData = [NSMutableData data];
    
    // 拼接数据总长度
    unsigned int dataLength = 4+4+(int)data.length;
    NSData *lengthData = [NSData dataWithBytes:&dataLength length:4];
    [mData appendData:lengthData];
    
    // 拼接数据类型
    NSData *typeData = [NSData dataWithBytes:&dataType length:4];
    [mData appendData:typeData];
    
    // 最后拼接实际数据
    [mData appendData:data];
    
    NSLog(@"发送数据的总字节大小: %ld",mData.length);
    
    // 发送数据
    [self.socket writeData:mData withTimeout:-1 tag:10086];
}

#pragma mark - 心跳

// 设置心跳机制
- (void)setupHeartBeat
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self destoryHeartBeat];
        
        __weak typeof(self) weakSelf = self;
        self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:15 repeats:YES block:^(NSTimer * _Nonnull timer) {
            __weak typeof(self) strongSelf = weakSelf;

            NSData *heartData = [@"heartBeat" dataUsingEncoding:NSUTF8StringEncoding];
            [strongSelf.socket writeData:heartData withTimeout:-1 tag:10086];
            NSLog(@"heartBeat");
        }];
    });
}

// 销毁心跳机制
- (void)destoryHeartBeat
{
    dispatch_main_async_safe(^{
        if (self.heartTimer && [self.heartTimer respondsToSelector:@selector(isValid)] && [self.heartTimer isValid])
        {
            [self.heartTimer invalidate];
            self.heartTimer = nil;
        }
    });
}

#pragma mark - 重连机制

// 重连Socket
- (void)reconnectSocket
{
    // 1、关闭socket
    [self disconnectSocket];
    
    // 2.1 超时判断
    if (self.reconnectTime > 64)
    {
        NSLog(@"网络超时，不再重连");
        return;
    }
    
    // 2.2 延时等待重连
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.reconnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self connectSocketOrCreate];
    });
    
    // 3、超时时长处理
    if (self.reconnectTime == 0)
    {
        self.reconnectTime = 2;
    }
    else
    {
        // 2^5 = 64（重连次数）
        self.reconnectTime *= 2;
    }
}

// 关闭socket
- (void)disconnectSocket
{
    if (self.socket)
    {
        [self.socket disconnect];
        self.socket.delegate = nil;
        self.socket = nil;
        [self destoryHeartBeat];
    }
}

#pragma mark - 创建socket进行连接

- (void)connectSocketOrCreate
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
        [self.socket connectToHost:@"127.0.0.1" onPort:8060 withTimeout:-1 error:&error];
        if (error) NSLog(@"%@",error);
    }
}

#pragma mark - GCDAsyncSocketDelegate

// 已经连接到服务器
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(nonnull NSString *)host port:(uint16_t)port{
    
    NSLog(@"连接成功，主机：%@，端口：%d",host,port);
    [self.socket readDataWithTimeout:-1 tag:10086];
}

// 断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"断开socket连接，错误原因：%@",err);
    
    // 进行重连
    [self reconnectSocket];
}

// 已经接收服务器返回来的数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到tag = %ld，长度 = %ld 的数据",tag,data.length);
    
    // 获取总的数据包大小
    NSData *totalSizeData = [data subdataWithRange:NSMakeRange(0, 4)];
    unsigned int totalSize = 0;
    [totalSizeData getBytes:&totalSize length:4];
    NSLog(@"响应总数据的大小 %u",totalSize);
    
    // 获取指令类型
    NSData *commandIdData = [data subdataWithRange:NSMakeRange(4, 4)];
    unsigned int commandId = 0;
    [commandIdData getBytes:&commandId length:4];
    
    // 获取数据上传结果
    NSData *resultData = [data subdataWithRange:NSMakeRange(8, 4)];
    unsigned int result = 0;
    [resultData getBytes:&result length:4];
    
    NSMutableString *str = [NSMutableString string];
    if (commandId == kcImageDataType)
    {
        [str appendString:@"图片 "];
    }
    
    if(result == 1)
    {
        [str appendString:@"上传成功"];
    }
    else
    {
        [str appendString:@"上传失败"];
    }
    NSLog(@"已经接收服务器返回来的数据：%@",str);
    
    [self.socket readDataWithTimeout:-1 tag:10086];
}

// 成功向服务器发送消息
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"%ld 成功向服务器发送消息",tag);
}

@end
