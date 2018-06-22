# JHFilterDemo
一个简单的滤镜生成器 可以调试滤镜效果  点击保存按钮即可打印当前的滤镜参数
## 前言
女孩子都喜欢用美图工具进行图片美容，近来无事时，特意为某人写了个自定义图片滤镜生成器，安装到手机即可完成自定义滤镜渲染照片。app独一无二，虽简亦繁。


![JH定律：
魔镜：最漂亮的女人是你老婆
魔镜：程序员不是木头人](http://upload-images.jianshu.io/upload_images/1687409-d62eac421b20e6a5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 核心技术
图片滤镜核心技术的基本思路如下：
![核心技术流程](http://upload-images.jianshu.io/upload_images/1687409-65edc35f81af85df.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 具体流程
### 1、创建一个图像处理工具类

######  注:该类实例包括一个图像处理方法，该方法在传入原始图像和一个颜色矩阵后生成一个处理好的图像。

     @interface JHFeilterManager : NSObject

    @property (nonatomic,copy)imageBlock imageBLOCK;

    - (UIImage *)createImageWithImage:(UIImage *)inImage colorMatrix:(const float *)f;

### 2、获取图像的每个像素点的RGBA值数组
######  注:该c方法返回一个指针，该指针指向一个数组，数组中的每四个元素都是图像上的一个像素点的RGBA的数值（0-255），用无符号的char是因为它正好的取值范围就是0-255

    static unsigned char *RequestImagePixelData(UIImage * inImage){  

        CGImageRef img = [inImage CGImage];
        CGSize size = [inImage size];
        //使用上面的函数创建上下文
        CGContextRef cgctx = CreateRGBABitmapContex(img);
        CGRect rect = {{0,0},{size.width,size.height}};
        //将目标图像绘制到指定的上下文，实际为上下文内的bitmapData。
        CGContextDrawImage(cgctx, rect, img);
        unsigned char *data = CGBitmapContextGetData(cgctx);
        //释放上面的函数创建的上下文
        CGContextRelease(cgctx);
        cgctx = NULL;
        return data;
    }

### 3、调整一个像素点的RGBA值
###### 注:如下方法传入参数为数值指针和一个颜色矩阵，通过颜色矩阵调整指针指向地址存储的数值
    static void changeRGB(int *red,int* green,int*blue,int*alpha ,const float *f){
        int redV = *red;
       int greenV = *green;
       int blueV = *blue;
       int alphaV = *alpha;
       //色值重新计算 计算规则如下
       *red = f[0] * redV + f[1]*greenV + f[2]*blueV + f[3] * alphaV + f[4];
       *green = f[5] * redV + f[6]*greenV + f[7]*blueV + f[8] * alphaV+ f[9];
       *blue = f[10] * redV + f[11]*greenV + f[12]*blueV + f[11] * alphaV+ f[14];
       *alpha = f[15] * redV + f[16]*greenV + f[17]*blueV + f[18] * alphaV+ f[19];
       *red < 0 ? (*red = 0):(0);
       *red > 255 ? (*red = 255):(0);
       *green < 0 ? (*green = 0):(0);
       *green > 255 ? (*green = 255):(0);
       *blue < 0 ? (*blue = 0):(0);
       *blue > 255 ? (*blue = 255):(0);
       *alpha < 0 ? (*alpha = 0):(0);
       *alpha > 255 ? (*alpha = 255):(0);
    }

### 4、遍历每个像素，调整色值

#### 注意！！！

在以下方法中，不要立刻释放malloc方法生成的bitmapData内存空间指针，（可能有的朋友觉得已经把内存空间地址给了位图上下文就可以立马释放掉了，但是实际上，由于位图上下文在后来的图像渲染时，仍然需要这一块内存，因此不能在此处立马释放掉内存，之前拜读的几篇博客索性就不释放内存了，因此会导致内存泄漏，处理一些高清图像时，手机内存会轻易飙升到1G以上，而导致程序挂掉）不然会导致位图上下文的内容数据不能正常存在而导致图片生成失败，在这里需要一个全局内存指针来指向它，并且在合适的时候释放内存。
###### 该方法中需要传入一个原始图片信息和一个颜色矩阵，颜色矩阵决定了图像的渲染效果，因此不同的滤镜效果可以通过设置不同的颜色矩阵进行转换，如果您不了解颜色矩阵，[点击这里进行了解](http://www.cnblogs.com/yjmyzz/archive/2010/10/16/1852878.html)
    - (UIImage *)createImageWithImage:(UIImage *)inImage colorMatrix:(const float *)f{
       /* 图片位图像素值数组 */
       unsigned char *imgPixel = RequestImagePixelData(inImage);
       CGImageRef inImageRef = [inImage CGImage];
       /* 获取像素的横向和纵向个数 */
       long w = CGImageGetWidth(inImageRef);
       long h = CGImageGetHeight(inImageRef);

       int wOff = 0;
       int pixOff = 0;
       /* 遍历修改位图像素值 */
       for (long y = 0; y<h; y++) {
           pixOff = wOff;
           for (long x = 0; x<w; x++) {
           int red = (unsigned char)imgPixel[pixOff];
           int green = (unsigned char)imgPixel[pixOff+1];
           int blue = (unsigned char)imgPixel[pixOff +2];
           int alpha = (unsigned char)imgPixel[pixOff +3];
           changeRGB(&red, &green, &blue, &alpha,f);
           imgPixel[pixOff] = red;
           imgPixel[pixOff + 1] = green;
           imgPixel[pixOff + 2] = blue;
           imgPixel[pixOff + 3] = alpha;
           pixOff += 4;
      }
    wOff += w * 4 ;
    }
      NSInteger dataLength = w * h * 4;
      //创建要输出的图像的相关参数
      CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
      if (!provider) {
        NSLog(@"创建输出图像相关参数失败！");
      }else{
        //每个像素点每个颜色的空间大小 单位为bit
        int bitsPerComponent = 8;
        //每个像素的空间大小 单位为bit
        int bitsPerPixel = 32;
        //每一行的颜色点的个数 每个像素有4个颜色点 每行有2个点
        ItemCount bytesPerRow = 4 * w;
        //创建RBGA色彩空间
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        //位图的组成部分信息
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
        //图像渲染参数 使用默认值
        CGColorRenderingIntent rederingIntent = kCGRenderingIntentDefault;
        //创建要输出的图像，参数依次为 宽、高、每个像素点的大小、每行占用空间大小、颜色空间、位图信息、相关输出参数
        CGImageRef imageRef = CGImageCreate(w, h,bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider,NULL, NO, rederingIntent);
        if (!imageRef) {
          NSLog(@"创建输出图像失败");
        }else{
          UIImage *my_image = [UIImage imageWithCGImage:imageRef];
          CFRelease(imageRef);
          CGColorSpaceRelease(colorSpaceRef);
          CGDataProviderRelease(provider);
      if (_imageBLOCK) {
        _imageBLOCK(my_image);
      }
      NSData *data = UIImageJPEGRepresentation(my_image, 1.0);
    //在此释放位图空间
      free(bitmap);
      return [UIImage imageWithData:data];
    }
    }
      return nil;
    }

### 5、UI搭建
UI界面非常简单，就是一张大图、20个颜色矩阵的信息录入框和两个按钮组成，代码就不过多赘述了，有需要的话可以到[这里](https://github.com/China131/JHFilterDemo.git)下载demo，喜欢的话不防给个star哦。

## 成果展示
成型的demo就是这个样子喽！


![Simulator Screen Shot 2017年1月4日 15.24.45.png](http://upload-images.jianshu.io/upload_images/1687409-bf929484d1ee0a84.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
