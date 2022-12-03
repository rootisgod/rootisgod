---
categories: linux keycloak oauth2-proxy website auth proxy
date: "2022-01-22T15:50:00Z"
title: Using Oauth2-Proxy to Protect Any Website
draft: true
---

I recently had a work project where there was a requirement to provide some kind of Single Sign on, or multi-factor authentication to a website. Easy enough you might think, but it was a 3rd party program and there was no way to configure these types of authentication settings. So, I needed to find a system which would allow me to connect to an Identity Provider and then allow the user to connect to the site once they authenticated. 

Let me start and say that Identity Providers and Authentication is not my strong suit, and it can be a nightmare a nightmare. I spent a long time trying to figure out a solution that wasn't tied to Okta, or Auth0 etc etc.. Luckily, I found a project called Oauth2-Proxy. This is a product which can connect to multiple IDPs and then act as a gateway to a website you want to protect. I haven't seen much good info on setting this up in a tutorial style, so I decided to hopefully save someone from having the difficulties I faced. 

## How To Set This Up

The example setup will run locally using Docker and Docker Compose. Hopefully you can extrapolate this out to your own use case once you 'see' it working. We need to set a couple of host entries to fool our system with some redirects, but in a real solution you will have internal or external DNS names to use and that won't be required.

### Our IDP
To keep it fairly simple, i'm going to use Keycloak as our 'remote' list of users that we need to login securely. In reality, our IDP of users can be anything that Oauth2-Proxy supports (Okta, Auth0, Google etc, se here: https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider) but this is teh simplest setup to demonstrate it working.

### Login FLow
The user will access our website URL, Oauth2-Proxy will authenticate the user and pass the request to Keycloak, and then allow access if successful.

```text
User -> Oauth2-Proxy -> Website
            /\
            ||
            \/
          Keycloak
```

## Host Entries

Add these entries to your local machine (Windows is ```c:\windows\system32\drivers\etc\hosts``` and Linux is ```/etc/hosts```)

```text
127.0.0.1 docker-webapp       docker-webapp.docker.local
127.0.0.1 docker-keycloak     docker-keycloak.docker.local
127.0.0.1 docker-oauth2-proxy docker-oauth2-proxy.docker.local
```

## Docker Compose File

This is the Docker compose file we will use. Copy teh text and name it ```docker-compose.yml``` It launches Keycloak, the Oauth2-Proxy and our website on the various required ports.

```dockerfile
version: "3.7"

services:
# NGINX
  # Listens on port 80 by default
  docker-webapp.docker.local:
    image: nginxdemos/hello
  # We want to hide this and have Oauth2 Proxy to it for us
    ports:
      - 8181:80
# KEYCLOAK
  docker-keycloak.docker.local:
    image: quay.io/keycloak/keycloak:20.0.1
#    container_name: keycloak
    restart: unless-stopped
    environment:
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
    image: bitnami/oauth2-proxy:7.4.0
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
```


# How to Run 

## Webapp

```bash
docker compose up -d docker-webapp.docker.local
```

Check it runs at http://docker-webapp.docker.local:8181

## Keycloak

We first start the Keycloak container, like so (the -d means do it as a background task). This can take a good minute to start, so be patient.

```bash
docker compose up -d docker-keycloak.docker.local

[+] Running 2/2
 - Network drafts_default                           Created                                                                                                        0.0s
 - Container drafts-docker-keycloak.docker.local-1  Started  
```

We can then login to keycloak and setup our realms and users for testing a login.

### Setup Keycloak

The following instructions seem to be a happy path, so i've not tried to overthink what everything is for. 

- Login to keycloak: http://docker-keycloak:8080
- In the top left, click the dropdown arrow next to 'Master', and click 'Add a realm' and call it 'Website' (case is important)
- Go to 'Users' -> 'Add User' and add 'testuser' AND a made up email address, then ENSURE 'Email Verified' is set to 'On'. Then in credentials ensure password is 'Password1' and not temporary.
- Go to 'Clients' -> 'account' and set the dropdown 'Access Type' to 'Confidential'. This means users are required to authenticate to access this realm
- In the Website realm, got co Client 'Account' -> 'Settings' and change 'Valid Redirect URIs' from '/realms/Website/account/*' to '*'
- Create a Mapper in 'Clients' -> 'Account' -> 'Mappers' -> 'Create'. Choose a name like 'my-app-audience' and choose Mapper Type of 'Audience'. Set 'Add to ID token' and  'Add to access token' to 'On'.
- Test a login at http://docker-keycloak.docker.local:8080/auth/realms/Website/account/ and click 'Sign In'. Sign in with our 'testuser'. This should succeed
- Note down the Client secret at 'Clients' -> 'account' -> 'Credentials'. Paste into the docker compose file OAUTH2-PROXY service and entry 'OAUTH2_PROXY_CLIENT_SECRET'.

### Start Oauth2-Proxy
We can now start Oauth2-Proxy and it can now connect to the running keycloak instance we have.

docker compose up -d docker-oauth2-proxy.docker.local

Now try and login at http://docker-oauth2-proxy.docker.local:80

Choose to signin with Keycloak OIDC, it will redirect to keycloak. Done!

- OPTIONALS
- Create a mapper with Mapper Type 'Group Membership' and Token Claim Name 'groups'.
