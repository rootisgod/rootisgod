FROM ubuntu:18.04

RUN apt-get update && \
    apt install ruby-full build-essential zlib1g-dev curl wget apt-transport-https software-properties-common -y && \
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc && \
    echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc && \
    source ~/.bashrc && \
    gem install jekyll bundler && \
    jekyll -v && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    add-apt-repository universe && \
    apt-get install -y powershell && \
    pwsh --version && \
    apt-get install -f && \
    wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1 && \
    mv azcopy azcopy10
