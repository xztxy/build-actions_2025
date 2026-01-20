#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了,在此处可以增加插件
# 自行拉取插件之前请SSH连接进入固件配置里面确认过没有你要的插件再单独拉取你需要的插件
# 不要一下就拉取别人一个插件包N多插件的,多了没用,增加编译错误,自己需要的才好


# 后台IP设置
export Ipv4_ipaddr="192.168.15.1"            # 修改openwrt后台地址(填0为关闭)
export Netmask_netm="255.255.255.0"         # IPv4 子网掩码（默认：255.255.255.0）(填0为不作修改)
export Op_name="Momo_Lede"                # 修改主机名称为OpenWrt-123(填0为不作修改)

# 内核和系统分区大小(不是每个机型都可用)
export Kernel_partition_size="32"            # 内核分区大小,每个机型默认值不一样 (填写您想要的数值,默认一般16,数值以MB计算,填0为不作修改),如果你不懂就填0
export Rootfs_partition_size="512"            # 系统分区大小,每个机型默认值不一样 (填写您想要的数值,默认一般300左右,数值以MB计算,填0为不作修改),如果你不懂就填0

# 默认主题设置
export Mandatory_theme="argon"              # 将bootstrap替换您需要的主题为必选主题(可自行更改您要的,源码要带此主题就行,填写名称也要写对) (填写主题名称,填0为不作修改)
export Default_theme="argon"                # 多主题时,选择某主题为默认第一主题 (填写主题名称,填0为不作修改)

# 旁路由选项
export Gateway_Settings="0"                 # 旁路由设置 IPv4 网关(填入您的网关IP为启用)(填0为不作修改)
export DNS_Settings="0"                     # 旁路由设置 DNS(填入DNS,多个DNS要用空格分开)(填0为不作修改)
export Broadcast_Ipv4="0"                   # 设置 IPv4 广播(填入您的IP为启用)(填0为不作修改)
export Disable_DHCP="0"                     # 旁路由关闭DHCP功能(1为启用命令,填0为不作修改)
export Disable_Bridge="0"                   # 旁路由去掉桥接模式(1为启用命令,填0为不作修改)
export Create_Ipv6_Lan="0"                  # 爱快+OP双系统时,爱快接管IPV6,在OP创建IPV6的lan口接收IPV6信息(1为启用命令,填0为不作修改)

# IPV6、IPV4 选择
export Enable_IPV6_function="1"             # 编译IPV6固件(1为启用命令,填0为不作修改)(如果跟Create_Ipv6_Lan一起启用命令的话,Create_Ipv6_Lan命令会自动关闭)
export Enable_IPV4_function="0"             # 编译IPV4固件(1为启用命令,填0为不作修改)(如果跟Enable_IPV6_function一起启用命令的话,此命令会自动关闭)

# 替换OpenClash的源码(默认master分支)
export OpenClash_branch="0"                 # OpenClash的源码分别有【master分支】和【dev分支】(填0为关闭,填1为使用master分支,填2为使用dev分支,填入1或2的时候固件自动增加此插件)

# 个性签名,默认增加年月日[$(TZ=UTC-8 date "+%Y.%m.%d")]
export Customized_Information="$(TZ=UTC-8 date "+%Y.%m.%d 我命由我不由天")"  # 个性签名,你想写啥就写啥,(填0为不作修改)

# 更换固件内核
export Replace_Kernel="0"                    # 更换内核版本,在对应源码的[target/linux/架构]查看patches-x.x,看看x.x有啥就有啥内核了(填入内核x.x版本号,填0为不作修改)

# 设置免密码登录(个别源码本身就没密码的)
export Password_free_login="1"               # 设置首次登录后台密码为空（进入openwrt后自行修改密码）(1为启用命令,填0为不作修改)

# 增加AdGuardHome插件和核心
export AdGuardHome_Core="0"                  # 编译固件时自动增加AdGuardHome插件和AdGuardHome插件核心,需要注意的是一个核心20多MB的,小闪存机子搞不来(1为启用命令,填0为不作修改)

# 开启NTFS格式盘挂载
export Automatic_Mount_Settings="0"          # 编译时加入开启NTFS格式盘挂载的所需依赖(1为启用命令,填0为不作修改)

# 去除网络共享(autosamba)
export Disable_autosamba="1"                 # 去掉源码默认自选的luci-app-samba或luci-app-samba4(1为启用命令,填0为不作修改)

# 其他
export Ttyd_account_free_login="1"           # 设置ttyd免密登录(1为启用命令,填0为不作修改)
export Delete_unnecessary_items="1"          # 个别机型内一堆其他机型固件,删除其他机型的,只保留当前主机型固件(1为启用命令,填0为不作修改)
export Disable_53_redirection="1"            # 删除DNS强制重定向53端口防火墙规则(个别源码本身不带此功能)(1为启用命令,填0为不作修改)
export Cancel_running="0"                    # 取消路由器每天跑分任务(个别源码本身不带此功能)(1为启用命令,填0为不作修改)


###### Git稀疏克隆函数定义（必须在使用前定义）
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl || return 1
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@ || { cd ..; rm -rf $repodir; return 1; }
  mv -f $@ ../package/ 2>/dev/null || true
  cd .. && rm -rf $repodir
  return 0
}

###### Themes
# 拉取酷猫主题
git clone --depth=1 -b master https://github.com/sirpdboy/luci-theme-kucat package/luci-theme-kucat
git clone --depth=1 -b master https://github.com/sirpdboy/luci-app-kucat-config package/luci-app-kucat-config
# 拉取peditx主题
git clone --depth=1 -b main https://github.com/peditx/luci-theme-peditx package/luci-theme-peditx


# 添加Lucky
git clone --depth=1 -b main https://github.com/gdy666/luci-app-lucky package/lucky

# 拉取文件管理
git clone --depth=1 https://github.com/sbwml/luci-app-filemanager package/luci-app-filemanager

# 添加xwan（添加错误处理）
echo "正在克隆 xwan 插件..."
if git_sparse_clone master https://github.com/x-wrt/com.x-wrt luci-app-xwan; then
    echo "✓ xwan 插件克隆成功"
else
    echo "✗ xwan 插件克隆失败,跳过"
fi

##### 科学上网插件

# 从 xztxy/small-package 克隆特定插件（使用完整克隆方式）
echo "正在从 small-package 仓库克隆插件..."
if git clone --depth=1 -b main https://github.com/xztxy/small-package /tmp/small-package; then
    echo "仓库克隆成功,正在移动插件..."
    
    # 移动需要的插件
    if [ -d "/tmp/small-package/luci-app-syncdial" ]; then
        mv -f /tmp/small-package/luci-app-syncdial package/
        echo "✓ luci-app-syncdial 移动成功"
    else
        echo "✗ 未找到 luci-app-syncdial"
    fi
    
    if [ -d "/tmp/small-package/luci-app-nikki" ]; then
        mv -f /tmp/small-package/luci-app-nikki package/
        echo "✓ luci-app-nikki 移动成功"
    else
        echo "✗ 未找到 luci-app-nikki"
    fi
    
    if [ -d "/tmp/small-package/nikki" ]; then
        mv -f /tmp/small-package/nikki package/
        echo "✓ nikki 移动成功"
    else
        echo "✗ 未找到 nikki"
    fi
    
    # 清理临时目录
    rm -rf /tmp/small-package
    echo "插件处理完成"
else
    echo "警告: small-package 仓库克隆失败,跳过此步骤"
fi

echo "所有插件处理完成"

# 确保目录存在
mkdir -p "$(dirname "$CLEAR_PATH")" 2>/dev/null || true
mkdir -p "$(dirname "$DELETE")" 2>/dev/null || true

# 整理固件包时候,删除您不想要的固件或者文件,让它不需要上传到Actions空间(根据编译机型变化,自行调整删除名称)
if [ -n "$CLEAR_PATH" ]; then
    cat >"$CLEAR_PATH" <<-EOF
packages
config.buildinfo
feeds.buildinfo
sha256sums
version.buildinfo
profiles.json
openwrt-x86-64-generic-kernel.bin
openwrt-x86-64-generic.manifest
openwrt-x86-64-generic-squashfs-rootfs.img.gz
EOF
    echo "CLEAR_PATH 文件创建成功"
else
    echo "警告: CLEAR_PATH 变量未定义"
fi

# 在线更新时,删除不想保留固件的某个文件,在EOF跟EOF之间加入删除代码,记住这里对应的是固件的文件路径,比如: rm -rf /etc/config/luci
if [ -n "$DELETE" ]; then
    cat >>"$DELETE" <<-EOF
EOF
    echo "DELETE 文件创建成功"
else
    echo "警告: DELETE 变量未定义"
fi

echo "diy-part.sh 脚本执行完成"
