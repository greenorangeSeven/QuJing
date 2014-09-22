//
//  MainPageView.h
//  BeautyLife
//
//  Created by Seven on 14-7-29.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StewardFeeFrameView.h"
#import "RepairsFrameView.h"
#import "NoticeFrameView.h"
#import "ExpressView.h"
#import "LawView.h"
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"
#import "ADVDetailView.h"

#import "StewardPageView.h"
#import "CommunityView.h"
#import "ProjectCollectionView.h"
#import "VolunteerView.h"


@interface MainPageView : UIViewController<SGFocusImageFrameDelegate, UIActionSheetDelegate>
{
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    int advIndex;
    
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *pointsBtn;
@property (weak, nonatomic) IBOutlet UIImageView *advIv;

#pragma mark -按钮点击事件

- (IBAction)clickLAW:(UIButton *)sender;

#pragma mark 城市文化
- (IBAction)clickCityCulture:(UIButton *)sender;

#pragma mark 精选特价
- (IBAction)clickSubtle:(UIButton *)sender;

- (IBAction)zhiyuanzheAction:(UIButton *)sender;

#pragma mark 联盟商家
- (IBAction)clickBusiness:(UIButton *)sender;

- (IBAction)bianminAction:(UIButton *)sender;

- (IBAction)stewardFeeAction:(id)sender;
- (IBAction)BusniessAction:(id)sender;
- (IBAction)noticeAction:(id)sender;
- (IBAction)newsAction:(id)sender;
//魅力曲靖
- (IBAction)clickBBS:(id)sender;


- (IBAction)shareAction:(id)sender;
- (IBAction)advDetailAction:(id)sender;
- (IBAction)pointsAction:(id)sender;

@end
