#!/usr/bin/env bash

mkdir -p client

help ()
{
    echo  ' ================================================================ '
    echo  ' --ssl-date: ssl证书失效时间，默认3650；'
    echo  ' 使用示例:'
    echo  ' ./client-generate.sh --ssl-date=3650'
    echo  ' ================================================================'
}

case "$1" in
    -h|--help) help; exit;;
esac

if [[ $1 == '' ]];then
    help;
    exit;
fi

CMDOPTS="$*"
for OPTS in ${CMDOPTS};
do
    key=$(echo ${OPTS} | awk -F"=" '{print $1}' )
    value=$(echo ${OPTS} | awk -F"=" '{print $2}' )
    case "$key" in
        --ssl-date) SSL_DATE=${value} ;;
    esac
done

# ssl相关配置
SSL_DATE=${SSL_DATE:-3650}

if [[ -e ./client/client-key.pem ]]; then
  echo -e "\033[32m ====> 1. 发现已存在client私钥，备份"client-key.pem"为"client-key.pem".bak-`date +%Y%m%d`，然后重新创建 \033[0m"
  mv client/client-key.pem client/"client-key.pem".bak-`date +%Y%m%d`
  openssl genrsa -out client/client-key.pem 2048
else
  echo -e "\033[32m ====> 1.生成新的client私钥 \033[0m"
  openssl genrsa -out client/client-key.pem 2048
fi
echo -e "\033[32m ====> 2. 生成客户端SSL CSR  \033[0m"
openssl req -new -key client/client-key.pem -out client/client.csr -subj "/C=CN/ST=LiaoNing/L=ShenYang/O=Company/OU=Organization/CN=WL"

echo -e "\033[32m ====> 3. 生成客户端SSL CERT client/client-cert.pem \033[0m"
openssl x509 -req -days ${SSL_DATE} -sha1 -extensions v3_req -CA  cacerts.pem -CAkey cakey.pem  -CAserial cacerts.srl -in client/client.csr -out client/client-cert.pem

echo -e "\033[32m ====> 4. 验证客户端SSL CERT client/client-cert.pem \033[0m"
openssl verify -CAfile cacerts.pem  client/client-cert.pem

echo -e "\033[32m ====> 5. 验证客户端SSL CERT p12格式 client/client.p12} \033[0m"
openssl pkcs12 -export -clcerts -in client/client-cert.pem -inkey client/client-key.pem -out client/client.p12

echo -e "\033[32m ====> 6. 证书制作完成 \033[0m"
echo
echo -e "\033[32m ====> 7. 以YAML格式输出结果 \033[0m"
echo "----------------------------------------------------------"
echo "client/client-key.pem: |"
cat client/client-key.pem | sed 's/^/  /'
echo
echo "client/client.csr: |"
cat client/client.csr | sed 's/^/  /'
echo
echo "client/client-cert.pem |"
cat client/client-cert.pem | sed 's/^/  /'
echo