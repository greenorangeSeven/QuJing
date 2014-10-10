//
//  CouponGetView.h
//  QuJing
//
//  Created by Seven on 14-10-8.
//  Copyright (c) 2014年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponGetView : UIViewController

@property (weak, nonatomic) UIViewController *parentView;
@property (weak, nonatomic) NSString *couponId;
@property (weak, nonatomic) IBOutlet UITextField *amountLb;
@property (weak, nonatomic) IBOutlet UITextField *pwdLb;
- (IBAction)submitAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
