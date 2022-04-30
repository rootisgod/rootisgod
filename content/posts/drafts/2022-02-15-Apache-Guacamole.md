Install like so


https://guacamole.apache.org/doc/gug/installing-guacamole.html
https://kifarunix.com/install-apache-guacamole-on-ubuntu-20-04/

In theory this: sudo apt install libcairo2-dev libjpeg-turbo8-dev libjpeg62-dev libpng12-dev libtool-bin uuid-dev libossp-uuid-dev

This is for server

```bash
sudo apt install libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin uuid-dev libossp-uuid-dev freerdp2-dev
wget https://dlcdn.apache.org/guacamole/1.4.0/source/guacamole-server-1.4.0.tar.gz
tar -xzf guacamole-server-1.4.0.tar.gz
cd guacamole-server-1.4.0
./configure --with-init-dir=/etc/init.d
make
sudo make install
sudo ldconfig
```

This is for client

```bash
sudo apt install maven -y
wget https://dlcdn.apache.org/guacamole/1.4.0/source/guacamole-client-1.4.0.tar.gz
tar -xzf guacamole-client-1.4.0.tar.gz
cd guacamole-client-1.4.0
sudo mvn install
```


