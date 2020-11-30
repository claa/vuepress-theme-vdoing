#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
npm run docs:build

# 进入生成的文件夹
cd docs/.vuepress/dist

# deploy to github
if [ -z "$GITHUB_TOKEN" ]; then
  msg='deploy'
  githubUrl=git@github.com:xugaoyi/vuepress-theme-vdoing.git
else
  msg='来自github actions的自动部署'
  githubUrl=https://claa:${GITHUB_TOKEN}@github.com/claa/vuepress-theme-vdoing.git
  git config --global user.name "claa"
  git config --global user.email "736238785@qq.com"
fi
git init
git add .
git commit -m 'deploy'
git remote add origin https://claa:15735659458zxc@gitee.com/claa/vuepress-theme-vdoing.git
git push -u origin master

#git push -f git@gitee.com:claa/vuepress-theme-vdoing.git master:gh-pages


cd - # 退回开始所在目录
rm -rf docs/.vuepress/dist