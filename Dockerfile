FROM ubuntu:20.04

# Install hugo and other bits and bobs
RUN apt-get update && \
    apt install curl wget apt-transport-https git net-tools -y

RUN wget https://github.com/gohugoio/hugo/releases/download/v0.83.1/hugo_extended_0.83.1_Linux-64bit.deb && \
    dpkg -i hugo_extended_0.83.1_Linux-64bit.deb && \
    hugo version

# Install az cli for pushing build to Azure storage blob
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install azcopy to copy site to blob storage later
RUN wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1 && \
    mv azcopy azcopy10 && \
    cp azcopy10 /usr/bin/ && \
    chmod +x /usr/bin/azcopy10 && \
    rm azcopy_v10.tar.gz && \
    apt-get clean

EXPOSE 1313
