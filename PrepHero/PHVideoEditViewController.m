//
//  PHVideoEditViewController.m
//  PrepHero
//
//  Created by admin on 1/23/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import "PHVideoEditViewController.h"
#import "PHSavedTableViewCell.h"
#import "PHClipVideoInfo.h"

@interface PHVideoEditViewController ()<UITextFieldDelegate, UITextViewDelegate>
{
    NSMutableArray *clipList;
    UIImage *editButtonBackgroundImage;
    UIImage *saveButtonBackgraoundImage;
}
@end

@implementation PHVideoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self getvideoInformation];
    [self setUpView];
}

- (void) getvideoInformation {
    NSString *clipedVideoName = [_videoInfo objectForKey:ClipedVideoName];
    NSString *clipedVideoDescription = [_videoInfo objectForKey:ClipedDescription];
    clipList = [NSMutableArray arrayWithArray:[_videoInfo objectForKey:ClipedVideos]];
    [_txtVideoName setText:clipedVideoName];
    [_txtDescription setText:clipedVideoDescription];
}

- (void) setUpView {
    
    _buttonView.layer.cornerRadius = 5.0f;
    _btnUpdate.layer.cornerRadius = 5.0f;
    _txtVideoName.delegate = self;
    _txtDescription.delegate = self;
    _clipView.hidden = YES;
    _aboutView.hidden = NO;
    
    editButtonBackgroundImage = [UIImage buttonImageWithColor:[UIColor colorFromHexCode:WhiteButtonBackGroundColor] cornerRadius:3.0f shadowColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIImage *editButtonActiveBackgroundImage = [UIImage buttonImageWithColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] cornerRadius:3.0f shadowColor:[UIColor colorFromHexCode:WhiteButtonBackGroundColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    saveButtonBackgraoundImage = [UIImage buttonImageWithColor:[UIColor colorFromHexCode:GreenButtonBackgroundColor] cornerRadius:3 shadowColor:[UIColor colorFromHexCode:GreenButtonActiveColor] shadowInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    [_btnClips setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnClips setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnAbout setBackgroundImage:saveButtonBackgraoundImage forState:UIControlStateNormal];
    [_btnAbout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnUpdate setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
    [_btnUpdate setBackgroundImage:editButtonActiveBackgroundImage forState:UIControlStateHighlighted];
    [_btnUpdate setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
    [_btnUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnUpdateInfoClicked:(id)sender {
    
    [self saveVideoInfo];
}

- (IBAction)btnActionClicked:(UIButton *)sender {
    
    switch (sender.tag) {
        case 1:
            [_btnAbout setBackgroundImage:saveButtonBackgraoundImage forState:UIControlStateNormal];
            [_btnAbout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_btnClips setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
            [_btnClips setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
            _clipView.hidden = YES;
            _aboutView.hidden = NO;
            break;
        case 2:
            [_btnAbout setBackgroundImage:editButtonBackgroundImage forState:UIControlStateNormal];
            [_btnAbout setTitleColor:[UIColor colorFromHexCode:WhiteButtonActiveColor] forState:UIControlStateNormal];
            [_btnClips setBackgroundImage:saveButtonBackgraoundImage forState:UIControlStateNormal];
            [_btnClips setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _clipView.hidden = NO;
            _aboutView.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void) saveVideoInfo{
    NSMutableDictionary *videoInfo = [[NSMutableDictionary alloc] init];
    [videoInfo setValue:_txtVideoName.text forKey:ClipedVideoName];
    [videoInfo setValue:_txtDescription.text forKey:ClipedDescription];
    [videoInfo setValue:clipList forKey:ClipedVideos];
    PHClipVideoInfo *fileManager = [PHClipVideoInfo sharedInstance];
    [fileManager addVideoInfo:videoInfo fileName:ClipedVideos];
    [fileManager updateVideoInfo:_videoInfo toVideoInfo:videoInfo fileName:ClipedVideos];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



// tableView delegate method implement
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return clipList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHSavedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoSavedCell"];
    if (cell == nil) {
        NSArray *nibarray = [[NSBundle mainBundle] loadNibNamed:@"PHSavedTableViewCell" owner:self options:nil];
        cell = [nibarray objectAtIndex:0];
    }
    if (indexPath.row == 0) {
        cell.btnUpward.enabled = NO;
    }
    if (indexPath.row == clipList.count-1){
        cell.btnDownward.enabled = NO;
    }
    cell.btnRemove.tag = indexPath.row;
    [cell.btnRemove addTarget:self action:@selector(removeClipVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnUpward.tag = indexPath.row;
    [cell.btnUpward addTarget:self action:@selector(videoPositionUp:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnDownward.tag = indexPath.row;
    [cell.btnDownward addTarget:self action:@selector(videoPositionDown:) forControlEvents:UIControlEventTouchUpInside];

    NSString *assetPath = [clipList objectAtIndex:indexPath.row];
    cell.assetPath = assetPath;
    [cell setPLayData:assetPath];
    return cell;
}

- (IBAction) removeClipVideo:(UIButton *) sender{
    
    [clipList removeObjectAtIndex:sender.tag];
    [_tableClipView reloadData];
}

- (IBAction) videoPositionUp:(UIButton *)sender{
    [clipList exchangeObjectAtIndex:sender.tag withObjectAtIndex:sender.tag-1];
    [_tableClipView reloadData];
}

- (IBAction) videoPositionDown:(UIButton *)sender{
    [clipList exchangeObjectAtIndex:sender.tag withObjectAtIndex:sender.tag+1];
    [_tableClipView reloadData];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    textView.text = @"";
    return YES;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text  isEqual: @"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
