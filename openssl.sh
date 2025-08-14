#!/bin/bash
# 全局变量
CUR_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source $CUR_DIR/common.sh

function tool_info()
{
    LOG_DEBUG "             ####################                "
    LOG_DEBUG "           ########################              "
    LOG_DEBUG "         ############################            "
    LOG_DEBUG "       ################################          "
    LOG_DEBUG "     ####################################        "
    LOG_INFO '==================欢迎使用工具脚本======'
    LOG_INFO '作者：ahua'
    LOG_INFO '功能如下：'
    LOG_INFO '[1] ----------------------------------------生成CA根证书'
    LOG_INFO '[2] ----------------------------------------根据CA根生成服务端证书'
    LOG_INFO '[0] ----------------------------------------退出'
    LOG_INFO '=========================ENJOY IT!==============='
}
function generate_CA()
{
    LOG_WARNING "安装包已携带统一的CA根证书，正常情况下不需要再生成"
    read -p "请输入(y/n)" confirmation
        if [ "$confirmation" = "y" ]; then
            # 检查 openssl 是否已安装
        if ! command -v openssl &> /dev/null; then
            LOG_ERROR "错误：openssl 未安装，请先安装 openssl 工具。"
            return 1
        fi
        SSL_DIR=$CUR_DIR/ssl
        openssl genrsa -out $SSL_DIR/CA/openssl_CA.key 2048
        openssl req -utf8 -new -x509 -key $SSL_DIR/CA/openssl_CA.key -out $SSL_DIR/CA/openssl_CA.cer -days 36500 -subj "/C=AA/ST=AA/L=AA/O=AA"

        LOG_DEBUG "CA根证书已生成，文件位置: $SSL_DIR/CA/openssl_CA.key 和 $SSL_DIR/CA/openssl_CA.cer"
        LOG_SUCCESS "更新成功！请重启所有服务使其生效"
        fi

}

# 生成服务端证书
function generate_certificate()
{
    # 检查 openssl 是否已安装
    if ! command -v openssl &> /dev/null; then
        LOG_ERROR "错误：openssl 未安装，请先安装 openssl 工具。"
        return 1
    fi
    ### 生成方法
    LOG_DEBUG '填写对应的信息，根据生成文件改名自己想要的名称，默认是生成的文件名是server.key和server.cer'
    LOG_DEBUG '配置文件中默认*.pms.dakewe.com作为域名，如需修改，请在openssl.cnf中修改。增加对应的IP'
    # 通过RSA算法生成长度2048位的秘钥

    SSL_DIR=$CUR_DIR/ssl
    openssl genrsa -out $SSL_DIR/server.key 2048
    openssl req -utf8 -config $SSL_DIR/openssl.cnf -new -out $SSL_DIR/server.req -key $SSL_DIR/server.key -subj "/C=AA/ST=AA/L=AA/O=AA"

    # 根据根CA证书生成服务端公钥，本质上就是将签名请求文件进行签名最终得到服务器的公钥
    openssl x509 -req  -extfile $SSL_DIR/openssl.cnf -extensions v3_req -in $SSL_DIR/server.req -out $SSL_DIR/server.cer -CAkey $SSL_DIR/CA/openssl_CA.key -CA $SSL_DIR/CA/openssl_CA.cer -days 36500 -CAcreateserial -CAserial $SSL_DIR/serial

    PRIVATE_CERT="$SSL_DIR/server.cer"
    PUBLIC_KEY="$SSL_DIR/server.key"

    # 检查文件是否存在
    if [ ! -f "$PRIVATE_CERT" ]; then
        LOG_ERROR "$PRIVATE_CERT 不存在，操作失败。"
        return 1
    fi

    if [ ! -f "$PUBLIC_KEY" ]; then
        LOG_ERROR "$PUBLIC_KEY 不存在，操作失败。"
        return 1
    fi
    LOG_SUCCESS "生成成功！$PRIVATE_CERT $PUBLIC_KEY"
}

#####################################################
function main_menu() {
    while true; do
        tool_info
        read -p "请输入选项: " option
        case $option in
            1)
                generate_CA
                ;;
            2)
                generate_certificate
                ;;
            0)
                LOG_INFO "退出程序"
                exit 0
                ;;
            *)
                LOG_WARNING "无效的选项，请重新输入。"
                ;;
        esac
    done
}
main_menu