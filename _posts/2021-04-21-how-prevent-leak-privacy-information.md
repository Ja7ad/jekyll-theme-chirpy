---
title: How to Pervent Leak Privacy Information?
author: Javad Rajabzade
date: 2021-04-21 20:13:23 +0800
categories: [Tricks, Privacy]
tags: [privacy, leak, floc, Tricks]
pin: true
---

Tip and tricks for Prevent leak your privacy in internet (prevent google tracking) easyway step by step.

## How to Improve privacy in web?
1. Install [Firefox Browser](https://www.mozilla.org/en-US/firefox/all/)

2. Download Extensions :
    - [Adguard adblocker](https://addons.mozilla.org/en-US/firefox/addon/adguard-adblocker/)
    - [Chameleon](https://addons.mozilla.org/en-US/firefox/addon/chameleon-ext/)

3. Import Settings file `adguard.json` and `chameleon.json` for **Adguard adblocker** and **Chameleon** via `Import settings` button.

    - chameleon settings = `moz-extension://38e42f82-5c99-4aa3-8fea-2fb3f4e334eb/options/options.html`

    ```json
        {
    "config": {
        "enabled": true,
        "notificationsEnabled": true,
        "theme": "light",
        "hasPrivacyPermission": true
    },
    "excluded": [],
    "headers": {
        "blockEtag": true,
        "enableDNT": true,
        "referer": {
        "disabled": false,
        "xorigin": 0,
        "trimming": 0
        },
        "spoofAcceptLang": {
        "enabled": true,
        "value": "default"
        },
        "spoofIP": {
        "enabled": false,
        "option": 0,
        "rangeFrom": "",
        "rangeTo": ""
        }
    },
    "ipRules": [],
    "options": {
        "cookieNotPersistent": false,
        "cookiePolicy": "reject_trackers",
        "blockMediaDevices": true,
        "blockCSSExfil": true,
        "disableWebRTC": true,
        "firstPartyIsolate": true,
        "limitHistory": true,
        "protectKBFingerprint": {
        "enabled": true,
        "delay": 1
        },
        "protectWinName": true,
        "resistFingerprinting": true,
        "screenSize": "2560x1440",
        "spoofAudioContext": true,
        "spoofClientRects": true,
        "spoofFontFingerprint": true,
        "spoofMediaDevices": true,
        "timeZone": "US/Pacific",
        "trackingProtectionMode": "private_browsing",
        "webRTCPolicy": "disable_non_proxied_udp",
        "webSockets": "allow_all"
    },
    "profile": {
        "selected": "randomDesktop",
        "interval": {
        "option": 60,
        "min": 1,
        "max": 1
        }
    },
    "version": "0.21.22.1",
    "whitelist": {
        "enabledContextMenu": false,
        "defaultProfile": "none",
        "rules": []
    }
    }
    ```
    
    - adguard settings = `moz-extension://6414f74b-08fc-4a65-bb1f-2627ab353942/pages/options.html`

    ```json
    {"protocol-version":"1.0","general-settings":{"app-language":"en-US","allow-acceptable-ads":true,"show-blocked-ads-count":true,"autodetect-filters":true,"safebrowsing-enabled":true,"filters-update-period":21600000},"extension-specific-settings":{"use-optimized-filters":true,"collect-hits-count":false,"show-context-menu":false,"show-info-about-adguard":true,"show-app-updated-info":true},"filters":{"enabled-groups":[1,2,3,4,5,6,7,0],"enabled-filters":[208,10,13,14,16,1,224,2,3,4,6,7,8,9,102,103,104,105,106,107,108,109,110,111,112,113,114,115,118,119,120,121,122,123,201,202,203,206,210,212,213,214,216,217,218,220,221,222,223,226,227,228,230,231,232,233,234,235,236,237,238,243,244,245,246,247,11,101,207,215,242,15,204,225,229,5,239,240,241,219,249],"custom-filters":[],"user-filter":{"rules":"soft98.ir###a7d5x-header > a.a7d5x-link > img.a7d5x-image\nsoft98.ir###a7d5x-header > a.a7d5x-link > img.a7d5x-image\nsoft98.ir###a7d5x-s1pecial > div.a7d5x__inner > section.card:first-child\nsoft98.ir###sid2ebar > section.card:first-child\n##.a7d5x-image\n###a7d5x-s1pecial > div.a7d5x__inner\nmoeinsoft.com#@#.mc4wp-form","disabled-rules":""},"whitelist":{"inverted":false,"domains":[],"inverted-domains":[]}}}
    ```

4. Using any vpn for prevent leak ip (Shadowsocks servers, expressvpn, nord, etc...)

5. Check your [BrowserLeaks](https://browserleaks.com) - [Fingerprint](https://amiunique.org) - [Check Adblocker](https://adblock-tester.com)