## 自签名证书

> 1.服务端证书生成(单向)

    # 注意替换参数值
    # ssl-domain为域名
    # ssl-trusted-domain 如果想多个域名访问，则添加扩展域名（SSL_TRUSTED_DOMAIN）,多个扩展域名用逗号隔开；
    # ssl-date 证书有效期（单位:日）
    mkdir -p /ssl && cd ssl
    ./server-generate.sh --ssl-domain=www.weiliang.com --ssl-trusted-domain=www.test2.com \
    --ssl-trusted-ip=1.1.1.1,2.2.2.2,3.3.3.3 --ssl-size=2048 --ssl-date=3650
    
> 2.服务端证书生成（可选）

    # ssl-date 证书有效期（单位:日）
    ./server-generate.sh --ssl-date=3650
    
> 3.nginx服务端ssl配置样例

    server {
            listen 8088 ssl;
            ssl_protocols TLSv1.2;
            ssl_prefer_server_ciphers on;
            ssl_session_cache shared:SSL:10m;
            ssl_certificate      /ssl/server/server.crt;  #server证书公钥
            ssl_certificate_key  /ssl/server/server.key;  #server私钥
            ssl_client_certificate /ssl/cacerts.pem;  #根级证书公钥，用于验证各个二级client
            ssl_verify_client on;  #开启客户端证书验证（如非双向认证，不需配置此参数）
            location / {
                    root html;
                    index index.html;
            }
    }
 
> 4.导入客户端证书（可选）

    客户端导入/ssl/client/client.p12文件   