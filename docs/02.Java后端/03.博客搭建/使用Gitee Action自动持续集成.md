#  使用Gitee Action自动持续集成

## 背景

目前已经在gitee上搭建好了博客，具体效果如下：

![image-20201128210318655](https://gitee.com/claa/tuci/raw/master/img/image-20201128210318655.png)

<mark>[访问博客](http://claa.gitee.io/vuepress-theme-vdoing/)</mark>

## 问题

博客就像日记一样，会经常记录，所以发布的时候，越简单就越好。

github pages 直接用deploy.sh 脚本部署也挺方便的，不过我的博客是搭建在gitee 上的，这种方法不太适用。我看到开发这个[vuepress-theme-vdoing](https://doc.xugaoyi.com/vuepress-theme-vdoing-doc/) 主题元素的作者是使用的github action 自动集成在自己域名的网页上的.

所以我想采用gitee action 来自动发布gitee pages服务，整体思路就是

先在github 上push 自己的新博客，然后自动打包，然后把包上传到gitee上，再调用gitee action 自动发布gitee pages。

 

 