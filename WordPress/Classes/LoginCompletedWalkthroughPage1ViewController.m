//
//  NewLoginCompletedWalkthroughPage1ViewController.m
//  WordPress
//
//  Created by Sendhil Panchadsaram on 7/29/13.
//  Copyright (c) 2013 WordPress. All rights reserved.
//

#import "LoginCompletedWalkthroughPage1ViewController.h"
#import "WPNUXUtility.h"

@interface LoginCompletedWalkthroughPage1ViewController ()

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *verticalCenteringConstraint;
@property (nonatomic, strong) IBOutlet UIImageView *logo;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *description;
@property (nonatomic, strong) IBOutlet UIImageView *bottomDivider;

@end

@implementation LoginCompletedWalkthroughPage1ViewController

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

    self.titleLabel.text = NSLocalizedString(@"Track your site's statistics", @"NUX Second Walkthrough Page 1 Title");
    self.titleLabel.font = [WPNUXUtility titleFont];
    self.titleLabel.layer.shadowRadius = 2.0;
    
    self.description.text = NSLocalizedString(@"Learn what your visitors respond to so you can give them more of it", @"NUX Second Walkthrough Page 1 Description");
    self.description.font = [WPNUXUtility descriptionTextFont];
    self.description.layer.shadowRadius = 2.0;
}

- (UIView *)topViewToCenterAgainst
{
    return self.logo;
}

- (UIView *)bottomViewToCenterAgainst
{
    return self.bottomDivider;
}

@end
