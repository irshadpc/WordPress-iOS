//
//  ReaderCommentTableViewCell.m
//  WordPress
//
//  Created by Eric J on 5/7/13.
//  Copyright (c) 2013 WordPress. All rights reserved.
//

#import "ReaderCommentTableViewCell.h"
#import <DTCoreText/DTCoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+Gravatar.h"
#import "WordPressAppDelegate.h"

#define RCTVCVerticalPadding 5.0f;

@interface ReaderCommentTableViewCell()<DTAttributedTextContentViewDelegate>

@property (nonatomic, strong) ReaderComment *comment;
@property (nonatomic, strong) DTAttributedTextContentView *textContentView;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *threadView;

- (CGFloat)requiredRowHeightForWidth:(CGFloat)width tableStyle:(UITableViewStyle)style;
- (void)handleLinkTapped:(id)sender;
- (void)drawNestingLayers;

@end

@implementation ReaderCommentTableViewCell

+ (NSArray *)cellHeightsForComments:(NSArray *)comments
							  width:(CGFloat)width
						 tableStyle:(UITableViewStyle)tableStyle
						  cellStyle:(UITableViewCellStyle)cellStyle
					reuseIdentifier:(NSString *)reuseIdentifier {
	
	NSMutableArray *heights = [NSMutableArray arrayWithCapacity:[comments count]];
	ReaderCommentTableViewCell *cell = [[ReaderCommentTableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:reuseIdentifier];
	for (ReaderComment *comment in comments) {
		[cell configureCell:comment];
		CGFloat height = [cell requiredRowHeightForWidth:width tableStyle:tableStyle];
		[heights addObject:[NSNumber numberWithFloat:height]];
	}
	return heights;
	
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		CGFloat width = self.frame.size.width;

		self.backgroundView = nil;
		self.contentView.backgroundColor = [UIColor clearColor];
		
		[self.contentView addSubview:self.imageView]; // TODO: Not sure about this...
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		self.imageView.clipsToBounds = YES;
		[self.imageView setFrame:CGRectMake(10.0f, 10.0f, 20.0f, 20.0f)];
		self.imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		
		self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(width - (10.0f + 30.0f), 10.0f, 30.0f, 20.0f)];
		[_dateLabel setFont:[UIFont systemFontOfSize:14.0f]];
		_dateLabel.textColor = [UIColor grayColor];
		_dateLabel.textAlignment = NSTextAlignmentRight;
		_dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		_dateLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_dateLabel];
		
		self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 10.0f, (_dateLabel.frame.origin.x - 50.0f), 20.0f)];
		[_authorLabel setFont:[UIFont systemFontOfSize:14.0f]];
		_dateLabel.textColor = [UIColor grayColor];
		_authorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_authorLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:_authorLabel];
		
		self.textContentView = [[DTAttributedTextContentView alloc] initWithFrame:CGRectMake(0.0f, _authorLabel.frame.size.height + 10.0f, width, 44.0f)];
		_textContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_textContentView.backgroundColor = [UIColor clearColor];
		_textContentView.edgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 5.0f, 10.0f);
		_textContentView.delegate = self;
		_textContentView.shouldDrawLinks = NO;
		_textContentView.shouldDrawImages = NO;
		_textContentView.shouldLayoutCustomSubviews = NO;
		[self.contentView addSubview:_textContentView];
		
		self.threadView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, self.frame.size.height)];
		_threadView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_threadView.backgroundColor = [UIColor clearColor];
		[self addSubview:_threadView];

    }
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)layoutSubviews {
	[super layoutSubviews];
	
	// We have to manually update the indentation of the content view? wtf.
	CGRect frame = self.contentView.frame;
	frame.origin.x += (self.indentationWidth * self.indentationLevel);
	frame.size.width -= frame.origin.x;
	self.contentView.frame = frame;
	
	[self.imageView setFrame:CGRectMake(10.0f, 10.0f, 20.0f, 20.0f)];
	
	CGFloat width = self.contentView.frame.size.width;
	CGFloat height = [_textContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:width].height;
	
	_textContentView.frame = CGRectMake(0.0f, _authorLabel.frame.size.height + 10.0f, width, height);
	[_textContentView layoutSubviews];
	
	[self drawNestingLayers];
}


- (void)drawNestingLayers {
	_threadView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
	
	UIColor *baseColor = [UIColor colorWithRed:194.0f/255.0f green:216.0f/255.0f blue:235.0f/255.0f alpha:1.0];
	NSMutableArray *layers = [NSMutableArray array];
	for (NSInteger i = 0; i < self.indentationLevel; i++) {
		CGFloat darkness = 1.0f - (i * 0.05f);
		CGFloat h, s, b, a;
		[baseColor getHue:&h saturation:&s brightness:&b alpha:&a];
		
		UIColor *stepColor = [UIColor colorWithHue:h
										saturation:s
										brightness:(b * darkness)
											 alpha:a];

		CALayer *layer = [CALayer layer];
		layer.backgroundColor = stepColor.CGColor;
		layer.frame = CGRectMake((self.indentationWidth * i), 0.0f, self.indentationWidth, self.frame.size.height);
		[layers addObject:layer];
	}
	
	[_threadView.layer setSublayers:layers];
}


- (CGFloat)requiredRowHeightForWidth:(CGFloat)width tableStyle:(UITableViewStyle)style {
	
	CGFloat desiredHeight = self.authorLabel.frame.size.height + 15.0f; // author + padding above, below, and between
	
	// Do the math. We can't trust the cell's contentView's frame because
	// its not updated at a useful time during rotation.
	CGFloat contentWidth = width;
	
	// reduce width for accessories
	switch (self.accessoryType) {
		case UITableViewCellAccessoryDisclosureIndicator:
		case UITableViewCellAccessoryCheckmark:
			contentWidth -= 20.0f;
			break;
		case UITableViewCellAccessoryDetailDisclosureButton:
			contentWidth -= 33.0f;
			break;
		case UITableViewCellAccessoryNone:
			break;
	}
	
	// reduce width for grouped table views
	if (style == UITableViewStyleGrouped) {
		contentWidth -= 19;
	}
	
	// Cell indentation 
	contentWidth -= (self.indentationLevel * self.indentationWidth);
	
	desiredHeight += [_textContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:contentWidth].height;
	
	return desiredHeight;
}


- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self.imageView cancelImageRequestOperation];
	self.imageView.image = nil;
	_authorLabel.text = @"";
	_dateLabel.text = @"";
	_textContentView.attributedString = nil;
}


- (void)configureCell:(ReaderComment *)comment {
	self.comment = comment;
	
	self.indentationWidth = 10.0f;
	self.indentationLevel = [comment.depth integerValue];
	
	[self.contentView addSubview:self.imageView];
	
	_dateLabel.text = [comment shortDate];
	_authorLabel.text = comment.author;
	[self.imageView setImageWithURL:[NSURL URLWithString:comment.authorAvatarURL] placeholderImage:[UIImage imageNamed:@"blavatar-wpcom.png"]];
	_textContentView.attributedString = [self convertHTMLToAttributedString:comment.content withOptions:nil];
}


- (NSAttributedString *)convertHTMLToAttributedString:(NSString *)html withOptions:(NSDictionary *)options {
    NSAssert(html != nil, @"Can't convert nil to AttributedString");
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
														  DTDefaultFontFamily: @"Helvetica",
										   NSTextSizeMultiplierDocumentOption: [NSNumber numberWithFloat:1.3]
								 }];
	
	if(options) {
		[dict addEntriesFromDictionary:options];
	}
	
    return [[NSAttributedString alloc] initWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding] options:dict documentAttributes:NULL];
}


- (void)handleLinkTapped:(id)sender {
	NSDictionary *dict = @{@"URL":((DTLinkButton *)sender).URL};
	[[NSNotificationCenter defaultCenter] postNotificationName:ReaderCommentCellLinkTappedNotification object:nil userInfo:dict];
}


#pragma mark - DTAttributedTextContentView Delegate Methods

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame {
	NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
	
	NSURL *URL = [attributes objectForKey:DTLinkAttribute];
	NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
	
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = URL;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
	
	// get image with normal link text
	UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
	[button setImage:normalImage forState:UIControlStateNormal];
	
	// get image for highlighted link text
	UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
	[button setImage:highlightImage forState:UIControlStateHighlighted];
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(handleLinkTapped:) forControlEvents:UIControlEventTouchUpInside];
	
	return button;
}


@end