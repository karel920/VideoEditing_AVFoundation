//
//  PHVideoEditViewController.m
//  PrepHero
//
//  Created by admin on 1/23/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHVideoEditViewController.h"
#import "PHVideosEditTableViewCell.h"

@interface PHVideoEditViewController ()<UITextFieldDelegate, UITextViewDelegate>

@end

@implementation PHVideoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpView];
}

- (void) setUpView{
    
    _buttonView.layer.cornerRadius = 5.0f;
    _txtVideoName.delegate = self;
    _txtDescription.delegate = self;
    _clipView.hidden = YES;
    _aboutView.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnUpdateInfoClicked:(id)sender {
}

- (IBAction)btnActionClicked:(UIButton *)sender {
    
    switch (sender.tag) {
        case 1:
            [_btnAbout setBackgroundImage:[UIImage imageNamed:@"GreenButton"] forState:UIControlStateNormal];
            _btnAbout.titleLabel.textColor = [UIColor whiteColor];
            [_btnClips setBackgroundImage:[UIImage imageNamed:@"Button"] forState:UIControlStateNormal];
            _btnAbout.titleLabel.textColor = [UIColor whiteColor];
            _btnClips.titleLabel.textColor = [UIColor darkGrayColor];
            _clipView.hidden = YES;
            _aboutView.hidden = NO;
            break;
        case 2:
            [_btnAbout setBackgroundImage:[UIImage imageNamed:@"Button"] forState:UIControlStateNormal];
            _btnAbout.titleLabel.textColor = [UIColor whiteColor];
            [_btnClips setBackgroundImage:[UIImage imageNamed:@"GreenButton"] forState:UIControlStateNormal];
            _btnAbout.titleLabel.textColor = [UIColor darkGrayColor];
            _btnClips.titleLabel.textColor = [UIColor whiteColor];
            _clipView.hidden = NO;
            _aboutView.hidden = YES;
            break;
            
        default:
            break;
    }
}

// tableView delegate method implement
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHVideosEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoEditCell"];
    if (cell == nil) {
        NSArray *nibarray = [[NSBundle mainBundle] loadNibNamed:@"PHVideosEditTableViewCell" owner:self options:nil];
        cell = [nibarray objectAtIndex:0];
    }
    
    return cell;
}
@end
