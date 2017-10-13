#!/bin/bash
#################################################################################
#
#       Type     :      环境部署
#       Function :      安装旺旺需要的依赖环境如python,redis..
#       Usage    :      ./install_env.sh
#       Creator  :      梁修军(04/06/2015)
#       Modifier :      梁修军(04/06/2015)
#
#################################################################################

install_pkg(){
    pkgname=$1
    pkgs=$(/bin/ls "$pkgname"*.tar.gz)
    tar -zxf $pkgs
    cd $pkgname
}
install_python(){
    pyversion=$(python -V 2>&1)
    if [ "$pyversion" = "Python 2.7.10" ];then
        echo "python 2.7.10 already installed."
    else
        echo "Starting install Python2.7.10"
        OSversion=$(cat /etc/issue|grep release|awk '{print $3}'|awk -F"." '{print $1}')
        if [  $OSversion != 5 -a $OSversion != 6 ];then
            echo "please select CentOS 5 or centos6 version of the installation"
            exit 0
        else
            wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-$OSversion.repo
            pkgs=( 'automake' 'gcc' 'gcc-c++' 'make' 'libtool' 'zlib' 'zlib-devel' 'openssl' 'openssl-devel' 'bzip2' 'readline' 'readline-devel')  
            for pkg in ${pkgs[@]};do
                rpm -q $pkg >/dev/null
                if [ "$?" -ge 1 ];then
                    echo "install $pkg,please wait.."
                    yum -y install $pkg
                    [ $? -ge 1 ] && echo "$pkg installation failure,exit"
                else
                    echo "$pkg package already installed."
                fi
            done   
        fi
	install_pkg Python-2.7.10
        sed -i '218,221s/#//' Modules/Setup.dist
        sed -i '437s/#//' Modules/Setup.dist
        sed -i '/zlib zlibmodule/s/#//' Modules/Setup.dist
        ./configure --prefix=/usr/local/python27
        make
        make install
        make clean 
        make distclean
        mv /usr/bin/python2.7 /usr/bin/python_old
        ln -s /usr/local/python27/bin/python /usr/bin/python2.7
        ls |grep -v install_env|grep -v tar.gz|xargs  rm -rf {}\;
        cd .. 
    fi
}

install_pip(){
    pip=$(pip -V 2>&1)
    if [ "$?" -ge "1" ];then
        install_pkg setuptools-18.0.1 
        python2.7 setup.py build
        python2.7 setup.py install
        cd ..
        install_pkg pip-7.1.0
        python2.7 setup.py build
        python2.7 setup.py install
        ln -s /usr/local/python27/bin/pip /usr/bin/pip
        cd ..
        sed -i '/\/usr\/local\/python27/d' /etc/profile
        echo "export PATH=/usr/local/python27/bin:\$PATH" >>/etc/profile
        . /etc/profile
    else
        echo "pip already installed"
    fi
}
install_redis(){
    redis=$(redis-server -v 2>&1)
    if [ "$?" -ge "1"  ];then
        echo "Starting install redis server."
        install_pkg redis-2.8.19
        make MALLOC=libc && make install
        cp redis.conf  /etc/redis.conf
        nohup redis-server &>/dev/null &
        cd ..
    else
        echo "redis-server already installed."

    fi
}

install_python_redis(){
    echo "Starting install python redis libs."
    install_pkg redis-2.10.3
    python setup.py install &>/dev/null 
    cd ..
}

install_python_aes(){
    echo "Starting install python pycrypto."
    install_pkg pycrypto-2.6.1
    python setup.py install &>/dev/null
    cd ..
}

install_python
install_pip
install_redis
install_python_redis
install_python_aes
