# wezterm

[English Version](./README_en.md)

这是 [SUI](https://github.com/shortcutui/sui) 在 [wezterm](https://wezfurlong.org/wezterm/index.html) 终端的实现. 主分支是个人在用的norman布局， 如果要用qwerty布局的， 需要自行修改，所有快捷键在 `keymaps.lua` 文件中.

## 依赖

这是终端[wezterm](https://wezfurlong.org/wezterm/index.html)的配置，因此需要安装好[wezterm](https://wezfurlong.org/wezterm/index.html)才能使用

## 安装

在管理员模式下打开 `install.bat` 即可.

## 卸载

安装脚本只会创建一个符号链接到[wezterm](https://wezfurlong.org/wezterm/index.html)的默认目录，因此只用
删除 `%USERPROFILE%\.config\wezterm` 文件即可， 然后删除本仓库.
