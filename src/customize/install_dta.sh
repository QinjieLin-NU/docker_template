wget \
https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
&& mkdir /root/.conda \
&& bash Miniconda3-latest-Linux-x86_64.sh -b  -p /opt/conda  \
&& rm -f Miniconda3-latest-Linux-x86_64.sh \
&& /opt/conda/bin/conda clean -tipsy  \
&& ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
&& echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc  \
&& echo "conda activate base" >> ~/.bashrc