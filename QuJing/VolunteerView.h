//
//  VolunteerView.h
//  QuJing
//
//  Created by Seven on 14-9-18.
//  Copyright (c) 2014年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"
#import "ArticleView.h"
#import "ADVDetailView.h"
#import "VolnJoinView.h"
#import "VolnView.h"

@interface VolunteerView : UIViewController<SGFocusImageFrameDelegate>
{
    UIWebView *phoneCallWebView;
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    int advIndex;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *telBg;
@property (weak, nonatomic) IBOutlet UIImageView *advIv;

- (IBAction)baomingAction:(UIButton *)sender;
- (IBAction)dongtaiAction:(UIButton *)sender;
- (IBAction)telAction:(id)sender;

@end
