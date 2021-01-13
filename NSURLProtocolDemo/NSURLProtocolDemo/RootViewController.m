//
//  RootViewController.m
//
//  Created by 谢佳培 on 2020/6/9.
//  Copyright © 2020 xiejiapei. All rights reserved.
//

#import "RootViewController.h"
#import "NSURLProtocolViewController.h"
#import "HTTPCookieViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) NSArray *vcTitles;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.vcTitles = @[@"NSURLProtocolDemo", @"HTTPCookieDemo",@"UIWebViewDemo",@"JavascriptBridgeDemo"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vcTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.vcTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            NSURLProtocolViewController *vc = [[NSURLProtocolViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:
        {
            HTTPCookieViewController *vc = [[HTTPCookieViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:
        {
            break;
        }
        case 3:
        {
            break;
        }
        default:
            break;
    }
}

@end
