//
//  DZNPhotoPickerController.m
//  DZNPhotoPickerController
//  https://github.com/dzenbot/DZNPhotoPickerController
//
//  Created by Ignacio Romero Zurbuchen on 10/5/13.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "DZNPhotoPickerController.h"
#import "DZNPhotoDisplayViewController.h"
#import "DZNPhotoServiceFactory.h"

#import <MobileCoreServices/UTCoreTypes.h>

static DZNPhotoPickerControllerFinalizationBlock _finalizationBlock;
static DZNPhotoPickerControllerFailureBlock _failureBlock;
static DZNPhotoPickerControllerCancellationBlock _cancellationBlock;

@interface DZNPhotoPickerController ()
@property (nonatomic, getter = isEditing) BOOL editing;
@property (nonatomic, assign) UIImage *editingImage;
@end

@implementation DZNPhotoPickerController

- (id)init
{
    self = [super init];
    if (self) {
        
        self.allowsEditing = NO;
        self.enablePhotoDownload = YES;
        self.allowAutoCompletedSearch = YES;
        
        self.supportedServices = DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr;
        self.supportedLicenses = DZNPhotoPickerControllerCCLicenseBY_ALL;
        self.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    }
    return self;
}

- (instancetype)initWithEditableImage:(UIImage *)image
{
    NSAssert(image, @"Expecting a non-nil image for using the editor.");
    
    self = [super init];
    if (self) {
        
        self.editingImage = image;
        self.editing = YES;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeTop;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPickingPhoto:) name:DZNPhotoPickerDidFinishPickingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailPickingPhoto:) name:DZNPhotoPickerDidFailPickingNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.isEditing) [self showPhotoEditorController];
    else [self showPhotoDisplayController];
}


#pragma mark - Getter methods

+ (NSArray *)availableMediaTypesForSupportedServices:(DZNPhotoPickerControllerServices)services
{
    return @[(NSString *)kUTTypeImage];
}


#pragma mark - Setter methods

- (void)setTitle:(NSString *)title
{
    UIViewController *controller = [self.viewControllers firstObject];
    
    if ([controller isKindOfClass:[DZNPhotoDisplayViewController class]]) {
        controller.title = title;
    }
}

- (void)setSupportedServices:(DZNPhotoPickerControllerServices)services
{
    NSAssert(services > 0, @"You must support at least 1 service.");
    _supportedServices = services;
}

- (void)setCropMode:(DZNPhotoEditorViewControllerCropMode)mode
{
    if (mode != DZNPhotoEditorViewControllerCropModeNone) {
        _allowsEditing = YES;
    }
    
    _cropMode = mode;
}

- (void)setFinalizationBlock:(DZNPhotoPickerControllerFinalizationBlock)block
{
    if (block) {
        _finalizationBlock = [block copy];
    }
}

- (void)setCancellationBlock:(DZNPhotoPickerControllerCancellationBlock)block
{
    if (block) {
        _cancellationBlock = [block copy];
    }
}

- (void)setCropSize:(CGSize)size
{
    NSAssert(!CGSizeEqualToSize(size, CGSizeZero), @"'cropSize' cannot be zero.");
    
    _cropSize = size;
    _cropMode = DZNPhotoEditorViewControllerCropModeCustom;
}

+ (void)registerService:(DZNPhotoPickerControllerServices)service consumerKey:(NSString *)key consumerSecret:(NSString *)secret subscription:(DZNPhotoPickerControllerSubscription)subscription
{
    [DZNPhotoServiceFactory setConsumerKey:key consumerSecret:secret service:service subscription:subscription];
}


#pragma mark - DZNPhotoPickerController methods

/*
 * Shows the photo display controller.
 */
- (void)showPhotoDisplayController
{
    [self setViewControllers:nil];
    
    DZNPhotoDisplayViewController *controller = [[DZNPhotoDisplayViewController alloc] init];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPicker:)];
        [controller.navigationItem setRightBarButtonItem:cancel];
    }
    
    [self setViewControllers:@[controller]];
}

/*
 * Shows the photo editor controller.
 */
- (void)showPhotoEditorController
{
    [self setViewControllers:nil];
    
    DZNPhotoEditorViewController *controller = [[DZNPhotoEditorViewController alloc] initWithImage:_editingImage cropMode:_cropMode cropSize:_cropSize];
    [self pushViewController:controller animated:NO];
}

/*
 * Called by a notification whenever the user picks a photo.
 */
- (void)didFinishPickingPhoto:(NSNotification *)notification
{
    if (self.finalizationBlock) {
        self.finalizationBlock(self, notification.userInfo);
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPickerController:didFinishPickingPhotoWithInfo:)]){
        [self.delegate photoPickerController:self didFinishPickingPhotoWithInfo:notification.userInfo];
    }
}

/*
 * Called by a notification whenever the picking a photo fails.
 */
- (void)didFailPickingPhoto:(NSNotification *)notification
{
    if (self.failureBlock) {
        self.failureBlock(self, notification.userInfo[@"error"]);
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPickerController:didFailedPickingPhotoWithError:)]){
        [self.delegate photoPickerController:self didFailedPickingPhotoWithError:notification.userInfo[@"error"]];
    }
}


/*
 * Called whenever the user cancels the picker.
 */
- (void)cancelPicker:(id)sender
{
    DZNPhotoDisplayViewController *controller = (DZNPhotoDisplayViewController *)[self.viewControllers objectAtIndex:0];
    if ([controller respondsToSelector:@selector(stopLoadingRequest)]) {
        [controller stopLoadingRequest];
    }
    
    if (self.cancellationBlock) {
        self.cancellationBlock(self);
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPickerControllerDidCancel:)]) {
        [self.delegate photoPickerControllerDidCancel:self];
    }
}


#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _editingImage = nil;
    _initialSearchTerm = nil;
    _finalizationBlock = nil;
    _cancellationBlock = nil;
}


#pragma mark - View Auto-Rotation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
