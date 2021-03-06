FROM centos:centos6
MAINTAINER The CentOS Project <cloud-ops@centos.org>

#Install redhat-release
RUN rm -f /etc/centos-release;
ADD ./redhat-release /etc/

#Install development tools 
RUN yum -y groupinstall 'Development tools';
RUN yum -y install rpm-devel tar readline-devel zlib-devel libacl-devel vim wget

#Install kernels 
ADD ./kernels/* /tmp/
RUN /tmp/install_extra_kernel.sh

#Install lcov
RUN yum -y install perl perl-GD
ADD ./lcov/lcov-1.10-4.el6.noarch.rpm /tmp/
RUN rpm -hvi /tmp/lcov-1.10-4.el6.noarch.rpm
RUN rm -f /tmp/lcov-1.10-4.el6.noarch.rpm

#Install openssh-server
RUN yum install -y openssh-server
RUN echo 'root:test@123' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#As Jenkins node
RUN yum install -y java

#Update git
RUN yum remove -y git && \
    yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker

RUN wget https://www.kernel.org/pub/software/scm/git/git-2.10.0.tar.gz && \
    tar zxf git-2.10.0.tar.gz && \
    cd git-2.10.0 && \
    make -j4 prefix=/usr all install && \
    cd .. && rm -rf /git-2.10.0*

# Install google test
RUN yum install -y cmake
ADD ./googletest/release-1.8.0.zip /tmp
RUN cd /tmp && \
    unzip /tmp/release-1.8.0.zip && \
    cd googletest-release-1.8.0 && \
    cmake -DBUILD_SHARED_LIBS=ON -DBUILD_GTEST=ON -DBUILD_GMOCK=ON -DCMAKE_INSTALL_PREFIX=/usr && \
    make all install && \
    cd .. && rm -rf release-1.8.0.zip googletest-release-1.8.0

# Install C-Mock
ADD ./cmock/master.zip /tmp
RUN cd /tmp && unzip master.zip && \
    make -C /tmp/C-Mock-master PREFIX=/usr install && \
    cd .. && rm -rf /tmp/master.zip /tmp/C-Mock-master

ENTRYPOINT service sshd start && /bin/bash

CMD ["/bin/bash"]
