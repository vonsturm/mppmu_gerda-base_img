FROM centos:7

# User and workdir settings:

USER root
WORKDIR /root

RUN yum update -y
RUN yum install -y centos-release-scl
RUN yum install -y devtoolset-9

RUN echo "source /opt/rh/devtoolset-9/enable" >> /etc/bashrc

SHELL ["/bin/bash", "--login", "-c"]
RUN gcc --version

# Install yum/RPM packages:

RUN true \
    && sed -i '/tsflags=nodocs/d' /etc/yum.conf \
    && yum install -y \
        epel-release \
    && yum groupinstall -y "Development Tools" \
    && yum install -y \
        deltarpm \
        \
        wget \
        cmake \
        p7zip \
        nano vim zsh \
        git git-gui gitk svn \
    && dbus-uuidgen > /etc/machine-id


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install CMake:

COPY provisioning/install-sw-scripts/cmake-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/cmake/bin:$PATH" \
    MANPATH="/opt/cmake/share/man:$MANPATH"

RUN provisioning/install-sw.sh cmake 3.9.0 /opt/cmake


# Install CLHep and Geant4:

COPY provisioning/install-sw-scripts/clhep-* provisioning/install-sw-scripts/geant4-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/geant4/bin:/opt/clhep/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/geant4/lib64:/opt/clhep/lib:$LD_LIBRARY_PATH" \
    G4NEUTRONHPDATA="/opt/geant4/share/Geant4-10.6.3/data/G4NDL4.6" \
    G4LEDATA="/opt/geant4/share/Geant4-10.6.3/data/G4EMLOW7.9.1" \
    G4LEVELGAMMADATA="/opt/geant4/share/Geant4-10.6.3/data/PhotonEvaporation5.5" \
    G4RADIOACTIVEDATA="/opt/geant4/share/Geant4-10.6.3/data/RadioactiveDecay5.4" \
    G4SAIDXSDATA="/opt/geant4/share/Geant4-10.6.3/data/G4SAIDDATA2.0" \
    G4ABLADATA="/opt/geant4/share/Geant4-10.6.3/data/G4ABLA3.1" \
    G4PIIDATA="/opt/geant4/share/Geant4-10.6.3/data/G4PII1.3" \
    G4ENSDFSTATEDATA="/opt/geant4/share/Geant4-10.6.3/data/G4ENSDFSTATE2.2" \
    G4REALSURFACEDATA="/opt/geant4/share/Geant4-10.6.3/data/RealSurface2.1.1" \
    G4PARTICLEXSDATA="/opt/geant4/share/Geant4-10.6.3/data/G4PARTICLEXS2.1" \
    AllowForHeavyElements=1


RUN true \
    && yum install -y \
        expat-devel xerces-c-devel zlib-devel \
        libXmu-devel libXi-devel \
        mesa-libGLU-devel motif-devel mesa-libGLw qt-devel qt5-qtbase-gui \
    && provisioning/install-sw.sh clhep 2.4.1.3 /opt/clhep \
    && provisioning/install-sw.sh geant4 10.6.3 /opt/geant4


# Install CERN ROOT:

COPY provisioning/install-sw-scripts/root-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/root/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/root/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/root/man:$MANPATH" \
    PYTHONPATH="/opt/root/lib:$PYTHONPATH" \
    CMAKE_PREFIX_PATH="/opt/root;$CMAKE_PREFIX_PATH" \
    JUPYTER_PATH="/opt/root/etc/notebook:$JUPYTER_PATH" \
    \
    ROOTSYS="/opt/root"

RUN true \
    && yum install -y \
        libSM-devel \
        libX11-devel libXext-devel libXft-devel libXpm-devel \
        libXdmcp libXtst libxkbfile libXScrnSaver libXss.so.1 \
        libjpeg-devel libpng-devel \
        mesa-libGLU-devel \
    && provisioning/install-sw.sh root 6.06.08 /opt/root


# Install Jupyter:

RUN true \
    && yum install -y python3-pip python3-setuptools python3-devel \
    && pip3 install --upgrade pip \
    && pip3 install jupyter \
    && pip3 install jupyterlab metakernel

EXPOSE 8888


# Install requirements for GERDA Software:

RUN true \
    && yum install -y \
        readline-devel fftw-devel \
    && pip3 install arrow enum34 subprocess32 wheel \
    && pip3 install python-dateutil==2.7.5 luigi==2.8.3


# Install support for graphical applications:

RUN yum install -y \
    xorg-x11-server-utils mesa-dri-drivers glx-utils \
    xdg-utils \
    xorg-x11-server-Xvfb


# Install ImageMagick:

# Somehow prevents occasional problems with font in Geant4.
RUN yum install -y ImageMagick


# Install additional packages and clean up:

RUN yum install -y \
        numactl \
        pbzip2 zstd libzstd-devel \
        \
        lsb-core-noarch \
        \
        levien-inconsolata-fonts dejavu-sans-fonts \
        \
        xorg-x11-server-utils mesa-dri-drivers glx-utils \
        xdg-utils \
        \
        http://linuxsoft.cern.ch/cern/centos/7/cern/x86_64/Packages/parallel-20150522-1.el7.cern.noarch.rpm \
    && yum clean all


# Set container-specific SWMOD_HOSTSPEC:

ENV SWMOD_HOSTSPEC="linux-centos-7-x86_64-47a9aec0"


# Final steps

CMD /bin/bash
