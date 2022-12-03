---
categories: linux keycloak oauth website auth proxy
date: "2022-01-22T15:50:00Z"
title: Using Oauth2-Proxy to Protect Any Website
draft: true
---

Try setup Oauth2-Proxy --> Keycloak <--> Azure SAML

# How to Run

```bash
docker compose stop
docker compose rm
docker compose up -d
```

# Fun Links
This! THe redirects between internal and external are a massive pain - https://stackoverflow.com/questions/50670734/keycloak-in-docker-compose-network

# Status
Works! Uses basic keycloak authentication and can connect to the Nginx test site. To test with RDS and an external IDP. Simplest to test with RDS first to ensure the proxy part works as expected though.

This page helped show a simple example, that can somewhat be substituted with Keycloak. I needed OAUTH2_PROXY_UPSTREAMS and not OAUTH2_PROXY_UPSTREAM. Ughhhh.
https://developer.crossid.io/blog/oauth2-proxy

# Config
- Login to keycloak: http://docker-keycloak:8080
- CLick 'Add a realm' and call it 'Website' (case is important) 
- Go to 'Users' -> 'Add User' and add 'testuser' AND an email address, then ensure 'Email Verified' is set to 'On' (I will try remove this later, but for now just do it). Then in credentials ensure password is 'Password1' and not temporary. 
- Go to 'Clients' -> 'account' -> and change access type to 'Confidential. Hit 'Save'.
- Note down the Client secret at 'Clients' -> 'account' -> 'Credentials' and note the Secret. Paste into the docker file, recreate the Oauth2-Proxy container.
- In the Website realm, got co Client 'Account' -> 'Settings' and change 'Valid Redirect URIs' from '/realms/Website/account/*' to '*'
- Go to 'Clients' -> 'Account' and set Access Type to 'Confidential'. This means users are required to authenticate to acess this realm
- Create a Mapper in 'Clients' -> 'Account' -> 'Mappers' -> 'Create'. CHoose a name like 'my-app-audience' and choose Mapper Type of 'Audience'. Set 'Add to ID token' and  'Add to access token' to 'On'.
- Test a login at http://docker-keycloak:8018/auth/realms/Website/account/#/ and try to sign in. This should succeed

- OPTIONALS
- Create a mapper with Mapper Type 'Group Membership' and Token Claim Name 'groups'.

# https://developer.okta.com/blog/2022/07/14/add-auth-to-any-app-with-oauth2-proxy
# https://github.com/oauth2-proxy/oauth2-proxy/issues/1448
# https://developers.redhat.com/articles/2021/05/20/authorizing-multi-language-microservices-oauth2-proxy
# https://dev.to/koyeb/add-authentication-to-your-apps-using-oauth2-proxy-2nha

# Add to C:\windows\system32\drivers\etc\hosts
#  127.0.0.1 docker-webapp docker-webapp.docker.local
#  127.0.0.1 docker-mysql docker-mysql.docker.local
#  127.0.0.1 docker-keycloak docker-keycloak.docker.local
#  127.0.0.1 docker-oauth2-proxy docker-oauth2-proxy.docker.local

# - Keycloak:               http://docker-webapp.docker.local:8080
# - Website:                http://docker-webapp.docker.local:8181
# - Oauth2-Proxy (port 80): http://docker-oauth2-proxy.docker.local

version: "3.7"

# We want to remember the keycloak config we create on new deploys
volumes:
  docker-mysql-data:
    driver: local

services:
# NGINX
  # Listens on port 80 by default
  docker-webapp.docker.local:
    image: nginxdemos/hello:0.3
  # We want to hide this and have Oauth2 Proxy to it for us
    ports:
      - 8181:80
# MYSQL
  docker-mysql.docker.local:
    image: mysql:5.7
    volumes:
      - docker-mysql-data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: keycloak
      MYSQL_USER: keycloak
      MYSQL_PASSWORD: password
# KEYCLOAK
  docker-keycloak.docker.local:
    image: jboss/keycloak:16.1.1
#    container_name: keycloak
    depends_on:
      - docker-mysql.docker.local
    restart: unless-stopped
    environment:
      DB_VENDOR: MYSQL
      DB_ADDR: docker-mysql.docker.local
      DB_DATABASE: keycloak
      DB_USER: keycloak
      DB_PASSWORD: password
      KEYCLOAK_USER: admin
      KEYCLOAK_PASSWORD: Password123!?
      PROXY_ADDRESS_FORWARDING: true  #important for reverse proxy
      REDIRECT_SOCKET: http
      # https://stackoverflow.com/questions/50670734/keycloak-in-docker-compose-network:
      KEYCLOAK_FRONTEND_URL: http://docker-keycloak.docker.local:8080/auth
    ports:
      - 8080:8080
# OAUTH2-PROXY - https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#keycloak-oidc-auth-provider
  docker-oauth2-proxy.docker.local:
    image: bitnami/oauth2-proxy:7.3.0
    depends_on:
      - docker-keycloak.docker.local
    command:
      - --http-address
      - 0.0.0.0:80
    # Every command line argument can be specified as an environment variable by prefixing it with OAUTH2_PROXY_, capitalising it, and replacing hypens (-) with underscores (_).
    environment:
      # Required
      OAUTH2_PROXY_EMAIL_DOMAINS: '*'
      # This is the site to deliver to the user. Use the URL that OAUTH2-PROXY can see. NOT what the user can see. It will reverse proxy this to the user
      OAUTH2_PROXY_UPSTREAMS: http://docker-webapp.docker.local/test/
      OAUTH2_PROXY_PROVIDER: keycloak-oidc
      OAUTH2_PROXY_CLIENT_ID: account
      OAUTH2_PROXY_CLIENT_SECRET: YT1ZU442xjP2Z0ZldbXa6Nmq7xXwv4R6
      # Should match Oauth2-Proxy External Port. Stops an https redirect
      OAUTH2_PROXY_REDIRECT_URL: http://docker-oauth2-proxy.docker.local/oauth2/callback
      OAUTH2_PROXY_OIDC_ISSUER_URL: http://docker-keycloak.docker.local:8080/auth/realms/Website
      # Skip Oauth2-Proxy welcome sign-in page, go straight to auth/IDP
      # OAUTH2_PROXY_SKIP_PROVIDER_BUTTON: true
      # Invalid authentication via OAuth2: unable to obtain CSRF cookie: https://github.com/oauth2-proxy/oauth2-proxy/issues/1488
      OAUTH2_PROXY_COOKIE_DOMAINS: '.docker.local'
      OAUTH2_PROXY_WHITELIST_DOMAINS: '.docker.local'
      OAUTH2_PROXY_COOKIE_SECRET: NOT_USED_BUT_REQUIRED_VALUE_32b_
      # https://stackoverflow.com/questions/71353947/why-am-i-getting-a-csrf-403-from-oauth2-proxy-when-running-on-gke-but-not-locall:
      OAUTH2_PROXY_COOKIE_SECURE: false
    ports:
      - 80:80

