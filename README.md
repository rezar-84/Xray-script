# XRay-Reality management script

- A Reality management script written by pure shell
- Use VLESS-XTLS-UTLS-Reality configuration
- Realize the self -filling of the XRAY listening port
- Can be customized input UUID ，非标准 UUID 将使用 `Xray uuid -i "Custom string"` Map the transformation into UUIDv5
- accomplish dest Self -selection and self -filling
  - Implement self -fill dest TLSV1.3 and H2 verification
  - Implement self -fill dest 的 serverNames Automatic acquisition
  - Implement automatic Passing the domain name Passing the domain name andon serverNames Passing the domain name and CDN SNI Filter of the domain name, Dest If it is a sub -domain name, it will be added automatically serverNames 中
  - Realize the self -defined display of the self -filled DEST`fmovies.to/home` 时，client config 会显示 `spiderX: /home`
- Default configuration forbidden to return to China, advertising, BT
- be usable Docker deploy Cloudflare WARP Proxy
- accomplish geo Automatic update of files

## question

Use warp Open OpenAI Normal access, but still unable to log in.。

I have for the help of friends who have been in the United States to try. The same account, I ca n’t go, it ’s a solution to contact the administrator. He logs in directly. Maybe I didn’t brush. IP Reason:( 。

Need to access normally and can log in. Do not use the opening function I provided. Use the script[WARP One -key][fscarmen]Useful IP Later, according to[Divert WARP Client Proxy Methods][fscarmen-warpproxy]Revise `/usr/local/etc/xray/config.json`accomplish OpenAI Normal use.

## how to use

- wget

  ```sh
  wget --no-check-certificate -O ${HOME}/Xray-script.sh https://raw.githubusercontent.com/rezar-84/Xray-script/main/reality.sh && bash ${HOME}/Xray-script.sh
  ```

- curl

  ```sh
  curl -fsSL -o ${HOME}/Xray-script.sh https://raw.githubusercontent.com/rezar-84/Xray-script/main/reality.sh && bash ${HOME}/Xray-script.sh
  ```

## Script interface

```sh
--------------- Xray-script ---------------
 Version      : v2023-03-15(beta)
 Description  : Xray Management script
----------------- Load management ----------------
1. Install
2. renew
3. Uninstalled
----------------- Operation management ----------------
4. start up
5. stop
6. Restart
----------------- Configuration management ---------------
101. View configuration
102. Information statistics
103. Revise id
104. Revise dest
105. Revise x25519 key
106. Revise shortIds
107. Revise xray Listening port
108. Refresh the existing shortIds
109. Additional custom shortIds
110. use WARP Diversion, open OpenAI
----------------- other options ----------------
201. Update to the latest stable core core
202. Uninstall the excess kernel
203. Revise ssh port
204. Network connection optimization
-------------------------------------------
```

## Client configuration

| name                  | value                                       |
| :-------------------- | :------------------------------------------ |
| address               | IP Or the domain name of the server         |
| port                  | 443                                         |
| User ID               | xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx        |
| Flow Control          | xtls-rprx-vision                            |
| Transfer Protocol     | tcp                                         |
| Transfer layer safety | reality                                     |
| SNI                   | learn.microsoft.com                         |
| Fingerprint           | chrome                                      |
| PublicKey             | wC-8O2vI-7OmVq4TVNBA57V_g4tMDM7jRXkcBYGMYFw |
| shortId               | 6ba85179e30d4fc2                            |
| spiderX               | /                                           |

## Thank you

[Xray-core][Xray-core]

[REALITY][REALITY]

[chika0801 Xray Configuration file template][chika0801-Xray-examples]

[deploy Cloudflare WARP Proxy][haoel]

[cloudflare-warp Mirror image][e7h4n]

[WARP One -key][fscarmen]

**This script is for communication and use only. Do not use this script line illegal.The illegal land and illegal things will accept legal sanctions.**

[Xray-core]: https://github.com/XTLS/Xray-core "THE NEXT FUTURE"
[REALITY]: https://github.com/XTLS/REALITY "THE NEXT FUTURE"
[chika0801-Xray-examples]: https://github.com/chika0801/Xray-examples "chika0801 Xray 配置文件模板"
[haoel]: https://github.com/haoel/haoel.github.io#943-docker-%E4%BB%A3%E7%90%86 "使用 Docker 快速部署 Cloudflare WARP Proxy"
[e7h4n]: https://github.com/e7h4n/cloudflare-warp "cloudflare-warp 镜像"
[fscarmen]: https://github.com/fscarmen/warp "WARP 一键脚本"
[fscarmen-warpproxy]: https://github.com/fscarmen/warp/blob/main/README.md#Netflix-%E5%88%86%E6%B5%81%E5%88%B0-WARP-Client-ProxyWireProxy-%E7%9A%84%E6%96%B9%E6%B3%95 "Netflix 分流到 WARP Client Proxy、WireProxy 的方法"
