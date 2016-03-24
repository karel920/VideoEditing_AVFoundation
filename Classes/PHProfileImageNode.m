//
//  PHProfileImageNode.m
//  PrepHero
//
//  Created by Xinjiang Shao on 8/3/15.
//  Copyright (c) 2015 PrepHero, Inc. All rights reserved.
//

#import "PHProfileImageNode.h"
#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import "GVUserDefaults+PrepHero.h"


static const CGFloat kImageSize = 100.0f;
static const CGFloat kOuterPadding = 16.0f;
//static const CGFloat kInnerPadding = 10.0f;

@interface PHProfileImageNode ()
{
    CGSize _profileSize;
    
    ASNetworkImageNode *_imageNode;
}
@end

@implementation PHProfileImageNode


- (instancetype)initWithProfileURL:(NSString *)profileUrl
{
    if (!(self = [super init]))
        return nil;
    
    // profile image, with a solid background colour serving as placeholder
    _imageNode = [[ASNetworkImageNode alloc] init];
    _imageNode.backgroundColor = ASDisplayNodeDefaultPlaceholderColor();
    
    _imageNode.URL = [NSURL URLWithString:profileUrl];
    
    

    [self addSubnode:_imageNode];
    
    return self;
}

#if UseAutomaticLayout
- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    ASRatioLayoutSpec *imagePlaceholder = [ASRatioLayoutSpec newWithRatio:1.0 child:_imageNode];
    imagePlaceholder.flexBasis = ASRelativeDimensionMakeWithPoints(kImageSize);

    return
    [ASInsetLayoutSpec
     newWithInsets:UIEdgeInsetsMake(kOuterPadding, kOuterPadding, kOuterPadding, kOuterPadding)
     child:
     [ASStackLayoutSpec
      newWithStyle:{
          .direction = ASStackLayoutDirectionHorizontal,
          .spacing = kInnerPadding
      }
      children:@[imagePlaceholder]]];
}

// With box model, you don't need to override this method, unless you want to add custom logic.
- (void)layout
{
    [super layout];
}
#else
- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
    CGSize imageSize = CGSizeMake(kImageSize, kImageSize);
    
    
    // ensure there's room for the text
    CGFloat requiredHeight = imageSize.height;
    return CGSizeMake(constrainedSize.width, requiredHeight + 2 * kOuterPadding);
}

- (void)layout
{

    _imageNode.frame = CGRectMake( self.calculatedSize.width / 2.0f - kImageSize / 2.0f, kOuterPadding, kImageSize, kImageSize);
    // Make circled profile image
    _imageNode.layer.cornerRadius = kImageSize / 2;
    _imageNode.clipsToBounds = YES;
    _imageNode.layer.borderWidth = 3.0f;
    _imageNode.layer.borderColor = [UIColor whiteColor].CGColor;
    

}
#endif

@end
