FROM ubuntu:18.04

# Install jekyll first to keep an early cache of the Jekyll install as it takes a while...
RUN apt-get update && \
    apt install ruby-full build-essential zlib1g-dev curl wget apt-transport-https software-properties-common git net-tools -y && \
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc && \
    echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc && \
    echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc && \
    gem install jekyll bundler && \
    jekyll -v

# Misc utils (az cli and powershell) for pushing build to Azure storage blob
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash && \
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell && \
    pwsh --version

# Install azcopy to copy site to blob storage later
RUN wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1 && \
    mv azcopy azcopy10 && \
    rm azcopy_v10.tar.gz && \
    apt-get clean

# Create a simple file to serve the site easily for testing
RUN echo 'cd /site && bundle install && jekyll serve --watch --host 0.0.0.0' >> /serve.sh && \
    chmod +x /serve.sh && \
    ls -lah /

EXPOSE 4000