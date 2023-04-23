# Xray-reality management script

- Reality management script written by pure shell
- Use VLESS-XTLS-URITY configuration
- Implement the self -filling of the XRAY listening port
- You can customize the input UUID. Non -standard UUID will use the `xray uuid -i" custom string "` ` ` ` `
- Realize the self -selection and self -filling of Dest
  - Implement the TLSV1.3 and H2 verification of the self -filled Dest
  - Realize the server of self -obtain automatic acquisition of DEST
  - Realize the filtering of the automatic obtained ServerNames incentive domain name and the CDN SNI domain name. DEST will automatically add it to Servernames if it is a sub -domain name
  - Realize the self -defined display of the SPIDERX self -filled Dest, for example: when the Dest is `fmovies.to /home`, the client config will display` spiderx: /home`
- Default configuration forbidden to return to China, advertising, BT
- You can use Docker to deploy Cloudflare Warp Proxy
- Implement automatic update of Geo files

## question

Although the normal access of OpenAI was opened using Warp, it still couldn't log in.

I have for the help of friends who have been in the United States to try. The same account, I ca n’t go here, and I have to contact the administrator to solve it. He ’s directly logging in to it. It may be because I did n’t brush the IP: (.

Need to access normally and can log in, do not use the opening function I provided, use the script [warp one-key hell] [fscarmen] to brush out the IP you can use, according to the method of [Fscarmen-method that is diverted to the warp client proxy]Warpproxy] Modify `/USR/LOCAL/ETC/XRAY/Config.json` to achieve the normal use of Openai.

## how to use

- WGET

  `` `SH
Wget --no-Check-CERTIFICATE -O $ {Home} /xray-script.sh https://raw.githubusercontent.com/zxcvos/xray-script/reality.sh & {Home}/XRay--script.sh `` `

- CURL

  `` `SH
Curl -FSSL -O $ {Home} /xray-script.sh https://raw.githubusercontent.com/zxcvos/xray-script/main/reality.sh && {Home} /xray-script.sh `` `

## script interface

## `` `SH

Version: v2023-03-15 (beta)
Description: xray management script

---

1. Installation
2. Update
3. UninStall

---

4. Start
5. STOP
6. Restart

---

101. View Configuration
102. Information
103. Modify ID
104. Modify Dest
105. Modify X25519 KEY
106. Modify Shortids
107. Modify xray Monitoring Port
108. Refresh The Existing Shortids
109. Additional Customized Shortids
110. Use Warp Diversion and Turn on Openai
     ---------------- other options ------------------------------------------------------------
111. Update to the Latest Stable Version Kernel
112. UninStall The Excess Kernel
113. Modify the ssh port
114. Network Connection Optimization

---

`` `

## client configuration

| Name                  | Value                                      |
| --------------------- | :----------------------------------------- | --- |
| Address               | IP or server domain name                   |
| Port                  | 443                                        |
| User ID               | xxxxxxx-xxxx-xxxx-xxxxxxxxxxxxx            |
| Flowing Control       | XTLS-RPRX-VISION                           |
| Transmission Protocol | TCP                                        |
| Transfer layer safety | Reality                                    |
| SNI                   | Learn.microSoft.com                        |
| Fingerprint           | Chrome                                     |
| Publickey             | WC-8O2VI-7MVQ4TVNBA57V_G4TMDM7JRXKCBYGMYFW |
| Shortid               | 6ba85179E30D4FC2                           |
| spiderx               | /                                          |     |

## thanks

[Xray-core] [xray-core]

[Reality] [Reality]

[chika0801 xray configuration file template] [chika0801-xray-spie

[Deploy Cloudflare Warp Proxy] [haoel]

[Cloudflare-WARP image] [E7H4N]

[WARP One -button Discovery] [FSCARMEN]

** This script is for communication and use only. Do not use this script line that illegally.The illegal land and illegal things will accept legal sanctions.**

[Xray-core]: https://github.com/Xtls/xray-core "The Next Future"
[Reality]: https://github.com/xtls/reality "the next future"
[chika0801-xray-examples]: https://github.com/chika0801/xray-examples "chika0801 xRay configuration file template"
[haoel]: https://github.com/haoel/haoel.github.io#943-docker-%E4%BB%A3%E7%90%86 "Use Docker to quickly deploy Cloudflare Warp Proxy"
[E7H4N]: https://github.com/e7h4n/Cloudflare-powerful
[fscarmen]: https://github.com/fscarmen/warp "warp one -key reward"
[fscarmen-narpprooxy]: https://github.com/fscarmen/blob/readme.md#netflix-%E5%886%E6%B5%88%B0-rient-ProxywireProxy-%E7%9A%84%E6%96%B9%E6%B3%95 "Netflix to Warp Client Proxy, WireProxy"
