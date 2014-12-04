//
//  AppDelegate.m
//  QuJing
//
//  Created by Seven on 14-9-14.
//  Copyright (c) 2014年 greenorange. All rights reserved.
//


#import "AppDelegate.h"

BMKMapManager* _mapManager;

@implementation AppDelegate
@synthesize mainPage;
@synthesize stewardPage;
@synthesize lifePage;
@synthesize shopCarPage;
//@synthesize tabBarController;
@synthesize cityPage;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //检查网络是否存在 如果不存在 则弹出提示
    [UserModel Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];
    //显示系统托盘
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    //初始化ShareSDK
    [ShareSDK registerApp:@"2cc31fa9badc"];
    [self initializePlat];
    
    //获取并保存用户信息
    [self saveUserInfo];
    [self saveAlipayKeyInfo];
    
    //首页
    self.mainPage = [[MainPageView alloc] initWithNibName:@"MainPageView" bundle:nil];
    UINavigationController *mainPageNav = [[UINavigationController alloc] initWithRootViewController:self.mainPage];
    
    // 要使用百度地图，请先启动BaiduMapManager
	_mapManager = [[BMKMapManager alloc]init];
	BOOL ret = [_mapManager start:@"C2rrk96MnTYQZxa67UPz2CjA" generalDelegate:self];
	if (!ret) {
		NSLog(@"manager start failed!");
	}
    //设置目录不进行IOS自动同步！否则审核不能通过
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [NSString stringWithFormat:@"%@/cfg", [paths objectAtIndex:0]];
    NSURL *dbURLPath = [NSURL fileURLWithPath:directory];
    [self addSkipBackupAttributeToItemAtURL:dbURLPath];
    [self addSkipBackupAttributeToPath:directory];
    
    [BPush setupChannel:launchOptions]; // 必须
    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法，本示例中为self
    // [BPush setAccessToken:@"3.ad0c16fa2c6aa378f450f54adb08039.2592000.1367133742.282335-602025"];  // 可选。api key绑定时不需要，也可在其它时机调用
//    [application registerForRemoteNotificationTypes:
//     UIRemoteNotificationTypeAlert
//     | UIRemoteNotificationTypeBadge
//     | UIRemoteNotificationTypeSound];
#if SUPPORT_IOS8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else
#endif
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:mainPageNav ];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    [BPush registerDeviceToken:deviceToken]; // 必须
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
}

// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
    if ([BPushRequestMethod_Bind isEqualToString:method])
    {
        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
        
        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [BPush handleNotification:userInfo]; // 可选
    //userInfo包含推送消息值及消息附加值
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UserModel Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];
    if ([UserModel Instance].isNetworkRunning == NO) {
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"未连接网络" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
		[myalert show];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveUserInfo
{
    UserModel *usermodel = [UserModel Instance];
    if ([usermodel isLogin]) {
        NSString *userinfoUrl = [NSString stringWithFormat:@"%@%@?APPKey=%@&tel=%@", api_base_url, api_getuserinfo, appkey, [usermodel getUserValueForKey:@"tel"]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:userinfoUrl]];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestUserinfo:)];
        [request startAsynchronous];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    
}

- (void)requestUserinfo:(ASIHTTPRequest *)request
{
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!json) {
        return;
    }
    User *user = [Tool readJsonStrToUser:request.responseString];
    int userid = [user.id intValue];
    if (userid > 0) {
        //设置登录并保存用户信息
        UserModel *userModel = [UserModel Instance];
        [userModel saveIsLogin:YES];
        [userModel saveValue:user.id ForKey:@"id"];
        [userModel saveValue:user.cid ForKey:@"cid"];
        [userModel saveValue:user.build_id ForKey:@"build_id"];
        [userModel saveValue:user.house_number ForKey:@"house_number"];
        [userModel saveValue:user.carport_number ForKey:@"carport_number"];
        [userModel saveValue:user.name ForKey:@"name"];
        [userModel saveValue:user.nickname ForKey:@"nickname"];
        [userModel saveValue:user.address ForKey:@"address"];
        [userModel saveValue:user.tel ForKey:@"tel"];
        [userModel saveValue:user.pwd ForKey:@"pwd"];
        [userModel saveValue:user.avatar ForKey:@"avatar"];
        [userModel saveValue:user.email ForKey:@"email"];
        [userModel saveValue:user.card_id ForKey:@"card_id"];
        [userModel saveValue:user.property ForKey:@"property"];
        [userModel saveValue:user.plate_number ForKey:@"plate_number"];
        [userModel saveValue:user.credits ForKey:@"credits"];
        [userModel saveValue:user.remark ForKey:@"remark"];
        [userModel saveValue:user.checkin ForKey:@"checkin"];
    }
}

- (void)saveAlipayKeyInfo
{
    NSString *userinfoUrl = [NSString stringWithFormat:@"%@%@?APPKey=%@", api_base_url, api_getAlipay, appkey];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:userinfoUrl]];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestAlipayInfo:)];
    [request startAsynchronous];
}

- (void)requestAlipayInfo:(ASIHTTPRequest *)request
{
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!json) {
        return;
    }
    AlipayInfo *alipay = [Tool readJsonStrToAliPay:request.responseString];
    if (alipay) {
        //保存支付宝信息
        UserModel *userModel = [UserModel Instance];
//        [userModel saveValue:alipay.DEFAULT_PARTNER ForKey:@"DEFAULT_PARTNER"];
//        [userModel saveValue:alipay.DEFAULT_SELLER ForKey:@"DEFAULT_SELLER"];
//        [userModel saveValue:alipay.PRIVATE ForKey:@"PRIVATE"];
//        [userModel saveValue:alipay.PUBLIC ForKey:@"PUBLIC"];
        [userModel saveDefaultPartner:alipay.DEFAULT_PARTNER];
        [userModel saveSeller:alipay.DEFAULT_SELLER];
        [userModel savePrivate:alipay.PRIVATE];
        [userModel savePublic:alipay.PUBLIC];
    }
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)addSkipBackupAttributeToPath:(NSString*)path {
    u_int8_t b = 1;
    setxattr([path fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}


//支付宝独立客户端回调函数
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"uoe:%@",query);
	[self parse:url application:application];
	return YES;
}

- (void)parse:(NSURL *)url application:(UIApplication *)application {
    
    //结果处理
    AlixPayResult* result = [self handleOpenURL:url];
//    shoppingBuyView
    NSString *fromView = [[UserModel Instance] getUserValueForKey:@"ailpayFromView"];
    
	if (result)
    {
		
		if (result.statusCode == 9000)
        {
			/*
			 *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
			 */
            
            //交易成功
            //UserModel *userModel = [UserModel Instance];
            NSString* key = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB";
            id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(key);
            if ([verifier verifyString:result.resultString withSign:result.signString])
            {
                if ([fromView isEqualToString:@"shoppingBuyView"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"buyOK" object:nil];
                }
//                stewardFeeView   sFeeOK
                else if ([fromView isEqualToString:@"stewardFeeView"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"sFeeOK" object:nil];
                }
//                parkFeeView
                else if ([fromView isEqualToString:@"parkFeeView"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"pFeeOK" object:nil];
                }
            }
        }
        else
        {
            //交易失败
            if ([fromView isEqualToString:@"shoppingBuyView"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"buyCancel" object:nil];
            }
            else if ([fromView isEqualToString:@"stewardFeeView"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sFeeCancel" object:nil];
            }
            else if ([fromView isEqualToString:@"parkFeeView"])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"pFeeCancel" object:nil];
            }
        }
    }
    else
    {
        //失败
        if ([fromView isEqualToString:@"shoppingBuyView"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"buyCancel" object:nil];
        }
        else if ([fromView isEqualToString:@"stewardFeeView"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sFeeCancel" object:nil];
        }
        else if ([fromView isEqualToString:@"parkFeeView"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pFeeCancel" object:nil];
        }
    }
    
}

- (AlixPayResult *)resultFromURL:(NSURL *)url {
	NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#if ! __has_feature(objc_arc)
    return [[[AlixPayResult alloc] initWithString:query] autorelease];
#else
	return [[AlixPayResult alloc] initWithString:query];
#endif
}

- (AlixPayResult *)handleOpenURL:(NSURL *)url {
	AlixPayResult * result = nil;
	
	if (url != nil && [[url host] compare:@"safepay"] == 0) {
		result = [self resultFromURL:url];
	}
    
	return result;
}

//初始化分享
- (void)initializePlat
{
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
//    [ShareSDK connectSinaWeiboWithAppKey:@"1434319718"
//                               appSecret:@"c1affea9508aa4d0f8ac8d580d092592"
//                             redirectUri:@"http://house.nwclhn.com"];
//    
    /**
     连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
     http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
     
     如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
     **/
    [ShareSDK connectTencentWeiboWithAppKey:@"801545642"
                                  appSecret:@"e132eba7a601cdf1de88ed521eb5ced9"
                                redirectUri:@"http://www.668app.com"
                                   wbApiCls:[WeiboApi class]];
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    [ShareSDK connectWeChatWithAppId:@"wxd8f6b7ac215ffe1d" wechatCls:[WXApi class]];
}

@end
