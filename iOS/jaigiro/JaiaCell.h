//
//  JaiaCell.h
//  jaigiro
//
//  Created by Sergio Garcia on 28/11/13.
//  Copyright (c) 2013 Irontec S.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JaiaCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *lButton;
@property (weak, nonatomic) IBOutlet UIView *lViewInfo;
@property (weak, nonatomic) IBOutlet UILabel *lLblJaia;
@property (weak, nonatomic) IBOutlet UIImageView *lImgKartela;
@property (weak, nonatomic) IBOutlet UIImageView *lImgCheck;



@property (weak, nonatomic) IBOutlet UIButton *rButton;
@property (weak, nonatomic) IBOutlet UIView *rViewInfo;
@property (weak, nonatomic) IBOutlet UILabel *rLblJaia;
@property (weak, nonatomic) IBOutlet UIImageView *rImgKartela;
@property (weak, nonatomic) IBOutlet UIImageView *rImgCheck;
@property (weak, nonatomic) IBOutlet UIImageView *rInfoImg;

@end
