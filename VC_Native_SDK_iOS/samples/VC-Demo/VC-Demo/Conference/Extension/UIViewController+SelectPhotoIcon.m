//
//  UIViewController+SelectPhotoIcon.m
//  BBSelectUserIcon
//
//  Created by 项羽 on 16/9/21.
//  Copyright © 2016年 项羽. All rights reserved.
//

#import "UIViewController+SelectPhotoIcon.h"



#define NAVBAR_COLOR    [UIColor whiteColor]

@implementation UIViewController (SelectPhotoIcon)


- (UIImagePickerController *)imagePickerController
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
//    [imagePickerController.navigationBar setBarTintColor:[UIColor clearColor]];
//    [imagePickerController.navigationBar setTintColor:[UIColor whiteColor]];
//    [imagePickerController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //隐藏返回按钮文字
//    [imagePickerController.navigationItem.backBarButtonItem setBackButtonTitlePositionAdjustment:UIOffsetMake(0, +60)forBarMetrics:UIBarMetricsDefault];
    
    
    
    return imagePickerController;
}



- (void)showActionSheet
{
    
    double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
    if(version >= 8.0f)
    {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *addPhoneAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self useCamera];
        }];
        
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self usePhoto];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [actionSheet addAction:addPhoneAction];
        [actionSheet addAction:photoAction];
        [actionSheet addAction:cancelAction];
        
        UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
        
        if (popover) {
            popover.sourceView = self.view;
            
            popover.sourceRect = CGRectMake(10, self.view.frame.size.height - 50, self.view.frame.size.width - 20, 50);
            
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [self presentViewController:actionSheet animated:true completion:nil];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相薄选择",@"拍照", nil];
        [actionSheet showInView:self.view];
#pragma clang diagnostic pop
        
    }
}

//选择相机时actionSheet点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //调用相机
    if (buttonIndex == 1)
    {
        [self useCamera];
    }
    else if (buttonIndex == 0)
    {
        [self usePhoto];
    }
}


-(void)useCamera{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker = self.imagePickerController;
        
        //允许编辑
        imagePicker.allowsEditing=true;
        //设置图片源
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //模态弹出IamgePickerView
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }else{
        NSLog(@"模拟器不支持拍照功能");
    }
    
}

-(void)usePhoto{
    
    UIImagePickerController *imagePicker = self.imagePickerController;

    //允许编辑
    imagePicker.allowsEditing = true;
    //设置图片源
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //模态弹出IamgePickerView
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//
//    //修复裁剪图片时出现导航栏的bug
//    if ([viewController isKindOfClass:NSClassFromString(@"PUUIImageViewController")]) {
//
//        [navigationController setNavigationBarHidden:YES animated:NO];
//    }else{
//
//        if ([viewController isKindOfClass:NSClassFromString(@"PLUICameraViewController")]) {
//            return;
//        }
//        [navigationController setNavigationBarHidden:NO animated:NO];
//
//    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;{
    
    
}



#pragma mark - 使用此分类需要实现这个代理拿到对应的图片
/*
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;{
    
        //获取照片的原图
//        UIImage *originalImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
    
        //获得编辑后的图片
//        UIImage *editedImage = (UIImage *)info[UIImagePickerControllerEditedImage];
    
    
        [picker dismissViewControllerAnimated:YES completion:nil];
}
*/



@end
