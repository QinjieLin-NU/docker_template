FROM nvidia/cudagl:11.0-devel-ubuntu18.04

# TensorFlow version is tightly coupled to CUDA and cuDNN so it should be selected carefully
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

ENV HOME=/root \
    INST=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1920x1080 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false \
    LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
WORKDIR $HOME

ENV NCCL_VERSION=2.4.7-1+cuda10.0

COPY ./src/common/install/ $INST_SCRIPTS/
COPY ./src/ubuntu/install/ $INST_SCRIPTS/
COPY ./src/common/xfce/ $INST/
COPY ./src/common/scripts $STARTUPDIR
COPY ./src/ubuntu/repo/sshd_config /etc/ssh/
ADD ./src/homeinit/ $INST/

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update -y \
        && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        build-essential \
        cmake \
        git \
        curl \
        vim \
        wget \
        ca-certificates \
        libnccl2=${NCCL_VERSION} \
        libnccl-dev=${NCCL_VERSION} \
        libjpeg-dev \
        libpng-dev \
        libnuma-dev \
        libtool \
        libglfw3-dev libglm-dev libx11-dev libomp-dev \
        libegl1-mesa-dev pkg-config \
        net-tools \
        iproute2 \
        iputils-ping \
        eog \
        unzip zip\
        tk-dev python-tk \
        openssh-server \
        ssh-askpass \
        software-properties-common \
        python python-dev python-setuptools \
        python3 python3-dev python3-setuptools \
        coinor-libcoinutils-dev  coinor-libclp-dev \
        coinor-libcbc-dev python-pip gnome-terminal \
        && apt clean -y \
        && apt autoremove -y \
        && rm -rf /var/lib/apt/lists/*

# Install related tools
RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4-Linux-x86_64.sh\
    && mkdir /opt/cmake \
    && sh cmake-3.13.4-Linux-x86_64.sh --prefix=/opt/cmake --skip-license \
    && ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake \
    && cmake --version
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} + \
    && $INST_SCRIPTS/tools.sh \
    && $INST_SCRIPTS/install_custom_fonts.sh \
    && $INST_SCRIPTS/tigervnc.sh \
    && $INST_SCRIPTS/no_vnc.sh  \
    && $INST_SCRIPTS/firefox.sh  \
    && $INST_SCRIPTS/chrome.sh  \
    && $INST_SCRIPTS/vscode.sh  \
    && $INST_SCRIPTS/xfce_ui.sh \
    && apt install -y sudo git \
    && $INST_SCRIPTS/libnss_wrapper.sh \
    && $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME $INST \
    && apt clean -y \
    && apt autoremove -y
RUN apt install -y sshpass libtool libtool-bin


#install own conda dependency
# COPY ./src/ros/install_ros.sh /$HOME/installation_dep/
# RUN sh /$HOME/installation_dep/install_ros.sh
# COPY ./src/ros/install_webots.sh /$HOME/installation_dep/
# RUN sh /$HOME/installation_dep/install_webots.sh
# COPY ./src/ros/install_ros2.sh /$HOME/installation_dep/
# RUN sh /$HOME/installation_dep/install_ros2.sh
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b  -p /opt/conda  \
    && rm -f Miniconda3-latest-Linux-x86_64.sh \
    && /opt/conda/bin/conda clean -tipsy  \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc  \
    && echo "conda activate base" >> ~/.bashrc

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" |  tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt-get install -y apt-transport-https ca-certificates gnupg \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get -y update && apt-get -y install google-cloud-sdk 

ENV PATH="/opt/conda/condabin:${PATH}"
COPY ./src/customize/conda_env.yml /$HOME/installation_dep/
RUN conda env create -f /$HOME/installation_dep/conda_env.yml 

SHELL ["/bin/bash", "--login", "-c"]
RUN conda init bash
RUN conda activate decision-transformer-atari \
    && pip install jupyter 
RUN conda activate decision-transformer-atari \
    && pip uninstall -y torch \
    && pip install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html

RUN conda create --name ray python=3.8.11
RUN conda activate ray \
    && pip install ray \  
    && pip install gym-minigrid \
    && pip install 'ray[tune]' \
    && pip install 'ray[rllib]' \
    && pip install pandas torch

#add install for paprallel torch module - deepspeed
RUN apt install -y libopenmpi-dev  
COPY ./src/customize/conda_env_minigrid.yml /$HOME/installation_dep/
RUN conda env create -f /$HOME/installation_dep/conda_env_minigrid.yml 

SHELL ["/bin/bash", "--login", "-c"]
RUN conda init bash
RUN conda activate decision-transformer-minigrid \
    && pip install jupyter 
RUN conda activate decision-transformer-minigrid \
    && pip uninstall -y torch \
    && pip install torch==1.9.0+cu111 torchvision==0.10.0+cu111 torchaudio==0.9.0 -f https://download.pytorch.org/whl/torch_stable.html

#===================important=================
COPY ./src/common/start_scripts/ $STARTUPDIR/
COPY ./src/common/bin/ /usr/local/bin/
COPY ./src/startup/ $STARTUPDIR/
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR 

# add users
WORKDIR $HOME
USER 0
ENTRYPOINT ["/dockerstartup/conda_startup.sh"]
CMD ["--wait"]
