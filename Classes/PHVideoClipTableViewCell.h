//
//  PHVideoClipTableViewCell.h
//  PrepHero
//
//  Created by admin on 1/24/16.
//  Copyright © 2016 PrepHero, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHVideoClipTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblVideoName;
@property (strong, nonatomic) IBOutlet UILabel *lblUserAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblClipTime;
@property (strong, nonatomic) IBOutlet UIImageView *videoPreviewImage;
@property (strong, nonatomic) NSManagedObject *videoData;
@property (strong, nonatomic) NSDictionary *videoInfo;

- (void) getdata: (NSManagedObject *) videoData info:(NSDictionary *)videoInfo;

@end
