//
//  ViewController.m
//  NSURLSsesionTest
//
//  Created by Vieene on 2016/11/1.
//  Copyright © 2016年 Vieene. All rights reserved.
//
//  block 方式采用隐式代理，代理方法部分就不能使用。  不使用block则可以直接代理方法

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDelegate>

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) NSMutableData *imageData;
@property (nonatomic,strong) NSURLResponse *reponse;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.imageView];
    _imageData = [NSMutableData data];
}
- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        CGRect frame = CGRectMake(30, 20, 300, 400);
        _imageView.frame = frame;
        _imageView.backgroundColor = [UIColor greenColor];
    }
    return _imageView;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [self test4];
}
//DataTask delegate
- (void)test4
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *se = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b10000_10000&sec=1477993241884&di=509e554fc9f72a17db43c066563f9e7c&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F9f510fb30f2442a79fbc68ded343ad4bd113021e.jpg"];
    
    NSURLSessionDataTask *dataTask = [se dataTaskWithURL:url];
    
    [dataTask resume];
}
//DataTask
- (void)test3
{
    __weak typeof(self) weakSelf = self;
    NSURL *URL = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b10000_10000&sec=1477993241884&di=509e554fc9f72a17db43c066563f9e7c&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F9f510fb30f2442a79fbc68ded343ad4bd113021e.jpg"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
        [weakSelf setImageWithData:data];
    }];
    [dataTask resume];
}
//downTask
- (void)test2
{
    NSURL *URL = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b10000_10000&sec=1477993241884&di=509e554fc9f72a17db43c066563f9e7c&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F9f510fb30f2442a79fbc68ded343ad4bd113021e.jpg"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request
                                                            completionHandler:
                                              ^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                  NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                                                  NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:documentsPath];
                                                  NSURL *newFileLocation = [documentsDirectoryURL URLByAppendingPathComponent:[[response URL] lastPathComponent]];
                                                  [[NSFileManager defaultManager] copyItemAtURL:location toURL:newFileLocation error:nil];
                                                  [session finishTasksAndInvalidate];
                                                  [self setImage:newFileLocation];
                                              }];
    
    [downloadTask resume];
}
// downTask delegate
- (void)test1
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *se = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b10000_10000&sec=1477993241884&di=509e554fc9f72a17db43c066563f9e7c&imgtype=0&src=http%3A%2F%2Fg.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F9f510fb30f2442a79fbc68ded343ad4bd113021e.jpg"];

    NSURLSessionDownloadTask *down = [se downloadTaskWithURL:url];
    
    [down resume];
}
- (void)setImage:(NSURL *)url
{
    NSLog(@"%@",url);

    [self setImageWithData:[NSData dataWithContentsOfURL:url]];
}
- (void)setImageWithData:(NSData *)imageData
{
    __weak ViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.imageView.image = [UIImage imageWithData:imageData];
    });
}
#pragma mark -NSURLSessionDownloadDelegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"%@------%lu",location,(unsigned long)downloadTask.taskIdentifier);
    [self setImage:location];
}
-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"%f / %f", (double)totalBytesWritten,
          (double)totalBytesExpectedToWrite);
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes;
{
    
}

#pragma mark -NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    if (error){
        // 下载失败
        
    }else{
        [self setImageWithData:_imageData];
    }
    
    [session finishTasksAndInvalidate];
    

}

#pragma mark -NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    _reponse = response;
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    
    [_imageData appendData:data];
}

@end
