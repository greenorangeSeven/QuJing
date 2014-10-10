//
//  CouponGetView.m
//  QuJing
//
//  Created by Seven on 14-10-8.
//  Copyright (c) 2014年 greenorange. All rights reserved.
//

#import "CouponGetView.h"
#import "UIViewController+CWPopup.h"

@interface CouponGetView ()

@end

@implementation CouponGetView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitAction:(id)sender {
    NSString *amountStr = self.amountLb.text;
    NSString *pwdStr = self.pwdLb.text;
    if (amountStr == nil || [amountStr length] == 0)
    {
        [Tool showCustomHUD:@"请输入金额" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (pwdStr == nil || [pwdStr length] == 0)
    {
        [Tool showCustomHUD:@"请输入密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    
    NSString *getUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_getcoupons];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:getUrl]];
    [request setUseCookiePersistence:NO];
    [request setPostValue:appkey forKey:@"APPKey"];
    [request setPostValue:self.couponId forKey:@"coupons_id"];
    [request setPostValue:[[UserModel Instance] getUserValueForKey:@"id"] forKey:@"userid"];
    NSLog([[UserModel Instance] getUserValueForKey:@"id"]);
    [request setPostValue:pwdStr forKey:@"password"];
    [request setPostValue:amountStr forKey:@"amount"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestGet:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在提交" andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}

- (void)requestGet:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    User *user = [Tool readJsonStrToUser:request.responseString];
    
    int errorCode = [user.status intValue];
    switch (errorCode) {
        case 1:
        {
            [Tool showCustomHUD:user.info andView:_parentView.view  andImage:@"37x-Checkmark.png" andAfterDelay:1];
            [_parentView dismissPopupViewControllerAnimated:YES completion:^{
                NSLog(@"popup view dismissed");
            }];
        }
            break;
        case 0:
        {
            [Tool showCustomHUD:user.info andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        }
            break;
    }
}

- (IBAction)cancelAction:(id)sender {
    [_parentView dismissPopupViewControllerAnimated:YES completion:^{
        NSLog(@"popup view dismissed");
    }];
}
@end
