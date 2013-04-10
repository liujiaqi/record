# 浪潮 AS500E 安装配置文档

## 0. 实验环境  

1. archlinux x86 64, kernel 版本 3.8.6, open-iscsi 版本 2.0-873  
2. Windows XP i686, iscsi initiator 版本 2.04  

## 1. 存储端

### 1.1 注册

记录机器的 sn, 机器码 2 个  
发送邮件给 somebody...  
得到注册码 2 个, 分别为...  

### 1.2 登录 web 界面

一台笔记本, 连接上交换机  

#### 1.2.1 Linux

Shell:  
``$ export NIC=$(ip link | grep enp | cut -d ' ' -f 2) | cut -d ':' -f 1``  
``$ sudo ip link set $NIC up``  
``$ sudo ip addr add 192.168.1.x/255.255.255.0 dev $NIC``  
``$ sudo ip route add default via 192.168.1.128``

``$ ping -c 3 192.168.1.128`` 测试一下　　

[note] CentOS 修改 /etc/sysconfig/network-scripts/ifcfg-eth0   

#### 1.2.2 Windows

设置本地网络　　

IP: 192.168.1.x  
NETMASK: 255.255.255.0  
GATEWAY: 192.168.1.128  

请参见 __图片1__

[note] x 为 1-254 且不为 128, 129 的整数  

打开浏览器, 输入 http://192.168.1.128 和 http://192.168.1.129  
[note] 如登录 129, 请修改网关地址

输入对应的注册码  
输入用户 root, 密码 root 登录 

### 1.3 新建卷组 

依此点击 _存储资源_, _卷组管理_, _新建卷组_  
选择所属控制器, 如 0  
选择 raid 类型, 如 raid0  
选择块大小, 如 128 kb? 默认...
按需要输入备注信息  
选择需要包含在卷族的硬盘, 如全选  
点击创建  

### 1.4 创建逻辑卷  

点击 _新建逻辑卷_  
输入 _逻辑卷名_
输入将要创建的空间大小  
选择 _缓存策略_, 如自动镜像  

## 1.5 管理主机组  

依此点击 _访问主机组_, _IPSAN主机组管理_  
点击 _新建主机组_  
输入 _主机组名_, 如 ipsan1  

[optional] 如需要双向认证, 输入 _target 密码_, 如 targetpasswd, 输入 _initiator 密码_, 如 targetinitia  
[note] 密码长度文档说不少于 12 位, 实践 12 位可以, 且貌似不能超过 16 位...  

点击增加  

## 1.6 增加主机  

[note] 因为此处需要 _发起端名_, 请跳至 __2.1__ 查看如何安装 iscsi initiator  

### 1.6.1 Linux  

shell 输入:
``$ cat /etc/iscsi/initiatorname.iscsi | cut -d '=' -f 2``
如返回 iqn.2005-03.org.open-iscsi:5c42fd55b6f  
这就是发起端名  

[note] 其他发行版没有测试, 应该也是相同的操作  

### 1.6.2 Windows  

双击 iscsi initiator 快捷方式  
见 __图片2__  
记录下发起端名  

[note] Windows 7 没有安装成功, Windows Server 2003 没有测试, 但应该可以  

其实登录存储后, 会显示发起端名, 直接复制添加也可以  

[note] 关于如何登录存储, 请跳至 __2.2__ 查看如何登录 iscsi 设备  

## 1.7 杂项

点击 _系统选项_  

### 1.7.1 [optional] 时间  

设置 ntp 服务器, ntp.tuna.tsinghua.edu.cn  
[note] 关于更多公共 ntp 服务器, 请上网搜索  

### 1.7.2 [optional] 配置管理  

点击 _配置下载_  
保存已下载的配置文件   

### 1.7.3 [optional] mail 设置  

点击 _编辑_ 编辑 _邮箱地址列表_, 如输入邮箱  

[note] 关于 _SMTP 邮箱服务器设置_, 请上网搜索, 如" 163 smtp"   

### 1.7.4 系统电源管理  

提供 _关机_ 和 _重启_ 操作  

# 2. 客户端

## 2.1 安装 iscsi initiator  

### 2.1.1 Linux

Shell:  
``$ wget https://aur.archlinux.org/open-iscsi/open-iscsi.tar.gz``
``$ tar zxvf open-iscsi.tar.gz``
``$ cd open-iscsi``
``$ makepkg``
``$ sudo pacman -Uy open-iscsi``

[note] 如使用 CentOS 或 Fedora, 请输入 ``sudo yum install -y open-iscsi-utils open-iscsi-utils-devel``, 没有测试  
[note] 如使用 Ubuntu 或 Debian, 请输入 ``apt-get install open-iscsi``, 没有测试    
[note] gentoo 或其他常用发行版, 请上网搜索或自行编译  

### 2.1.2 Windows

[note] 实验环境: Windows XP i686, iscsi initiator 软件为安装盘自带, 版本 2.04  

一路 _下一步_ 就安装好了  

## 2.2 登录存储  

### 2.2.1 Linux  

无论 with CHAP 或是 without CHAP, 都可以使用 _tools.sh_ 这个脚本完成  

### 2.2.2 Windows

pass;)  

[note] 如果使用 multipath, 建议使用 linux  

# 3. [optional] 超级终端  

## 3.1 登录

[note] 需要特定的串口连接线, 可能还需要串口 usb 转接线  
默认用户 dcs02, 密码 dcs02  

## 3.2 命令  

[note] 实验并没有详细操作  

超级终端提供有限操作  

1. hostname
2. ip
3. ping
4. dc network
5. dc stat
6. dc sysctl
7. logout
8. exit

详细请输入 <_command_> help 查看帮助信息  

# 4. multipath 设置  

[note] 以下测试只在 linux 下进行  

在同一个控制器上插上 2 条网线  

Shell:
``# wget https://aur.archlinux.org/packages/mu/multipath-tools/multipath-tools.tar.gz; tar zxvf multipath-tools.tar.gz``  
``# cd multipath-tools``  
``# sudo makepkg``  
``# sudo pacman -Uy multipath-tools``  
``# sudo cp multipath.conf /etc/multipath.conf``  
[note] 直接将提供的配置文件覆盖即可  

``# sudo multipathd``  
// return some infomation  
``# sudo multipath -ll``  
``# ll /dev/mapper``  
// directory information  

``# sudo pvscan``  
``# sudo pvcreate /dev/mapper/1494e53505552000038333134343031343734373831333335p1``  
...  
``# sudo vgcreate vg01 /dev/mapper/1494e53505552000038333134343031343734373831333335p1``  
...  
``# sudo lvcreate -L 3000G vg01 -n lv01``  
``# sudo mkfs.ext4 /dev/mapper/vg01-lv01``    
...  
``# sudo mkdir /mnt/lvm01``  
``# sudo mount /dev/mapper/vg01-lv01 /mnt/lvm01``  
``# df -h``  
// mount the lvm filesystem successfully

[note] 其他发行版操作基本相同  

// enable the daemon to start on boot  
``# sudo systemctl enable multipathd``  

[note] For CentOS, type ``sudo echo "service multipathd start" >> /etc/rc.d/rc.local``  
[note] If you want mount the LVM filesystem on boot, maybe you have to modify your _fstab_ file or you can write an easy shell script  
