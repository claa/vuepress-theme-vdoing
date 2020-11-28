@echo off
        
REM 构建生成静态文件
echo building...
call build.bat
echo building-complete
        
REM 进入生成的文件夹
cd docs/.vuepress/dist
        
REM 如果是发布到自定义域名
REM echo 'www.example.com' > CNAME
        
git init
git add -A
git commit -m 'deploy'
        
REM 如果发布到 https://gitee.com/<USERNAME>
REM git push -f git@github.com:<USERNAME>/<USERNAME>.github.io.git master
        
REM 如果发布到 https://gitee.com/<USERNAME>/<REPO>
git remote add origin https://gitee.com/claa/vuepress-theme-vdoing.git

git push -u origin master
        
cd ..
cd ..
cd ..
echo Auto-Deploy-Complete