#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e "\n Ups……por favor use ${red}root ${none}ejecución de usuario ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

case $sys_bit in
# i[36]86)
# 	v2ray_bit="32"
# 	caddy_arch="386"
# 	;;
'amd64' | x86_64)
	v2ray_bit="64"
	caddy_arch="amd64"
	;;
# *armv6*)
# 	v2ray_bit="arm32-v6"
# 	caddy_arch="arm6"
# 	;;
# *armv7*)
# 	v2ray_bit="arm32-v7a"
# 	caddy_arch="arm7"
# 	;;
*aarch64* | *armv8*)
	v2ray_bit="arm64-v8a"
	caddy_arch="arm64"
	;;
*)
	echo -e " 
	jaja... esto ${red}guión de pollo picante${none} Su sistema no es compatible. ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ sistema
	" && exit 1
	;;
esac

# 笨笨的检测方法
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

	if [[ $(command -v yum) ]]; then

		cmd="yum"

	fi

else

	echo -e " 
	jaja... esto ${red}guión de pollo picante${none} Su sistema no es compatible. ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ sistema
	" && exit 1

fi

uuid=$(cat /proc/sys/kernel/random/uuid)
old_id="e55c8d17-2cf3-b21a-bcf1-eeacb011ed79"
v2ray_server_config="/etc/v2ray/config.json"
v2ray_client_config="/etc/v2ray/233blog_v2ray_config.json"
backup="/etc/v2ray/233blog_v2ray_backup.conf"
_v2ray_sh="/usr/local/sbin/v2ray"
systemd=true
# _test=true

transport=(
	TCP
	TCP_HTTP
	WebSocket
	"WebSocket + TLS"
	HTTP/2
	mKCP
	mKCP_utp
	mKCP_srtp
	mKCP_wechat-video
	mKCP_dtls
	mKCP_wireguard
	QUIC
	QUIC_utp
	QUIC_srtp
	QUIC_wechat-video
	QUIC_dtls
	QUIC_wireguard
	TCP_dynamicPort
	TCP_HTTP_dynamicPort
	WebSocket_dynamicPort
	mKCP_dynamicPort
	mKCP_utp_dynamicPort
	mKCP_srtp_dynamicPort
	mKCP_wechat-video_dynamicPort
	mKCP_dtls_dynamicPort
	mKCP_wireguard_dynamicPort
	QUIC_dynamicPort
	QUIC_utp_dynamicPort
	QUIC_srtp_dynamicPort
	QUIC_wechat-video_dynamicPort
	QUIC_dtls_dynamicPort
	QUIC_wireguard_dynamicPort
	VLESS_WebSocket_TLS
)

ciphers=(
	aes-128-gcm
	aes-256-gcm
	chacha20-ietf-poly1305
)

_load() {
	local _dir="/etc/v2ray/233boy/v2ray/src/"
	. "${_dir}$@"
}
_sys_timezone() {
	IS_OPENVZ=
	if hostnamectl status | grep -q openvz; then
		IS_OPENVZ=1
	fi

	echo
	timedatectl set-timezone Asia/Shanghai
	timedatectl set-ntp true
	echo "ha configurado su host paraAsia/Shanghaizona horaria y pasesystemd-timesyncdSincronización horaria automática."
	echo

	if [[ $IS_OPENVZ ]]; then
		echo
		echo -e "su entorno de acogida es ${yellow}Openvz${none} ，Se recomienda utilizar${yellow}v2ray mkcp${none}serie de acuerdos."
		echo -e "Aviso：${yellow}Openvz${none} El tiempo del sistema no puede ser controlado y sincronizado por el programa dentro de la máquina virtual."
		echo -e "Si la hora del anfitrión es diferente de la hora real${yellow}超过90秒${none}，v2rayno será capaz de comunicarse correctamente，Por favor envíeticketconectarvpsAjuste empresa de acogida."
	fi
}

_sys_time() {
	echo -e "\nhora del anfitrión：${yellow}"
	timedatectl status | sed -n '1p;4p'
	echo -e "${none}"
	[[ $IS_OPENV ]] && pause
}
v2ray_config() {
	# clear
	echo
	while :; do
		echo -e "por favor elige "$yellow"V2Ray"$none" Protocolo de transferencia [${magenta}1-${#transport[*]}$none]"
		echo
		for ((i = 1; i <= ${#transport[*]}; i++)); do
			Stream="${transport[$i - 1]}"
			if [[ "$i" -le 9 ]]; then
				# echo
				echo -e "$yellow  $i. $none${Stream}"
			else
				# echo
				echo -e "$yellow $i. $none${Stream}"
			fi
		done
		echo
		echo "Nota 1: contener [dynamicPort] es decir, habilitar puertos dinámicos .."
		echo "Nota 2: [utp | srtp | wechat-video | dtls | wireguard] disfrazado de [BTdescargar | videollamada | Videollamada WeChat | DTLS 1.2 paquete de datos | WireGuard paquete de datos]"
		echo
		read -p "$(echo -e "(Protocolo predeterminado: ${cyan}TCP$none)"):" v2ray_transport
		[ -z "$v2ray_transport" ] && v2ray_transport=1
		case $v2ray_transport in
		[1-9] | [1-2][0-9] | 3[0-3])
			echo
			echo
			echo -e "$yellow V2Ray Protocolo de transferencia = $cyan${transport[$v2ray_transport - 1]}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done
	v2ray_port_config
}
v2ray_port_config() {
	case $v2ray_transport in
	4 | 5 | 33)
		tls_config
		;;
	*)
		local random=$(shuf -i20001-65535 -n1)
		while :; do
			echo -e "por favor escribe "$yellow"V2Ray"$none" Puerto ["$magenta"1-65535"$none"]"
			read -p "$(echo -e "(puerto predeterminado: ${cyan}${random}$none):")" v2ray_port
			[ -z "$v2ray_port" ] && v2ray_port=$random
			case $v2ray_port in
			[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
				echo
				echo
				echo -e "$yellow V2Ray Puerto = $cyan$v2ray_port$none"
				echo "----------------------------------------------------------------"
				echo
				break
				;;
			*)
				error
				;;
			esac
		done
		if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
			v2ray_dynamic_port_start
		fi
		;;
	esac
}

v2ray_dynamic_port_start() {

	while :; do
		echo -e "por favor escribe "$yellow"V2Ray inicio de puerto dinámico "$none"alcance ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(Puerto de inicio predeterminado: ${cyan}10000$none):")" v2ray_dynamic_port_start_input
		[ -z $v2ray_dynamic_port_start_input ] && v2ray_dynamic_port_start_input=10000
		case $v2ray_dynamic_port_start_input in
		$v2ray_port)
			echo
			echo " no puedo y V2Ray El puerto es como un pelo...."
			echo
			echo -e " Puerto V2Ray actual：${cyan}$v2ray_port${none}"
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			echo
			echo
			echo -e "$yellow V2Ray inicio de puerto dinámico = $cyan$v2ray_dynamic_port_start_input$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac

	done

	if [[ $v2ray_dynamic_port_start_input -lt $v2ray_port ]]; then
		lt_v2ray_port=true
	fi

	v2ray_dynamic_port_end
}
v2ray_dynamic_port_end() {

	while :; do
		echo -e "por favor escribe "$yellow"V2Ray Ingrese el extremo del puerto dinámico "$none"alcance ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(Puerto final predeterminado: ${cyan}20000$none):")" v2ray_dynamic_port_end_input
		[ -z $v2ray_dynamic_port_end_input ] && v2ray_dynamic_port_end_input=20000
		case $v2ray_dynamic_port_end_input in
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])

			if [[ $v2ray_dynamic_port_end_input -le $v2ray_dynamic_port_start_input ]]; then
				echo
				echo " No puede ser menor o igual que el rango de inicio del puerto dinámico de V2Ray"
				echo
				echo -e " El puerto dinámico V2Ray actual comienza：${cyan}$v2ray_dynamic_port_start_input${none}"
				error
			elif [ $lt_v2ray_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $v2ray_port ]]; then
				echo
				echo " Rango final de puerto dinámico V2Ray No puede incluir puertos V2Ray..."
				echo
				echo -e " Puerto V2Ray actual：${cyan}$v2ray_port${none}"
				error
			else
				echo
				echo
				echo -e "$yellow V2Ray extremo del puerto dinámico = $cyan$v2ray_dynamic_port_end_input$none"
				echo "----------------------------------------------------------------"
				echo
				break
			fi
			;;
		*)
			error
			;;
		esac

	done

}

tls_config() {

	echo
	local random=$(shuf -i20001-65535 -n1)
	while :; do
		echo -e "por favor escribe "$yellow"V2Ray"$none" por favor escribe ["$magenta"1-65535"$none"]，no puedo elegir "$magenta"80"$none" o "$magenta"443"$none" por favor escribe"
		read -p "$(echo -e "(puerto predeterminado: ${cyan}${random}$none):")" v2ray_port
		[ -z "$v2ray_port" ] && v2ray_port=$random
		case $v2ray_port in
		80)
			echo
			echo " ... dijeron que no puedes elegir el puerto 80 ..."
			error
			;;
		443)
			echo
			echo " .. dijeron que no puedes elegir el puerto 443..."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			echo
			echo
			echo -e "$yellow V2Ray Puerto = $cyan$v2ray_port$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done

	while :; do
		echo
		echo -e "por favor ingrese un ${magenta}nombre de dominio correcto${none}，Tiene que ser correcto, ¡no! ¡pueden! ¡afuera! ¡equivocado!"
		read -p "(Por ejemplo：233blog.com): " domain
		[ -z "$domain" ] && error && continue
		echo
		echo
		echo -e "$yellow tu nombre de dominio = $cyan$domain$none"
		echo "----------------------------------------------------------------"
		break
	done
	get_ip
	echo
	echo
	echo -e "$yellow por favor $magenta$domain$none $yellow resolver: $cyan$ip$none"
	echo
	echo -e "$yellow por favor $magenta$domain$none $yellow resolver: $cyan$ip$none"
	echo
	echo -e "$yellow por favor $magenta$domain$none $yellow resolver: $cyan$ip$none"
	echo "----------------------------------------------------------------"
	echo

	while :; do

		read -p "$(echo -e "(¿Está analizado correctamente?: [${magenta}Y$none]):") " record
		if [[ -z "$record" ]]; then
			error
		else
			if [[ "$record" == [Yy] ]]; then
				domain_check
				echo
				echo
				echo -e "$yellow DNS = ${cyan}seguro que ya está analizado$none"
				echo "----------------------------------------------------------------"
				echo
				break
			else
				error
			fi
		fi

	done

	if [[ $v2ray_transport -eq 4 ]]; then
		auto_tls_config
	else
		caddy=true
		install_caddy_info="Abierto"
	fi

	if [[ $caddy ]]; then
		path_config_ask
	fi
}
auto_tls_config() {
	echo -e "

		Instale Caddy para configurar automáticamente TLS
		
		Si tiene instalado Nginx o Caddy

		$yellowY... puedes hacer la configuración tú mismo TLS$none

		Entonces no necesita activar la configuración automática TLS
		"
	echo "----------------------------------------------------------------"
	echo

	while :; do

		read -p "$(echo -e "(Ya sea para configurar automáticamente TLS: [${magenta}Y/N$none]):") " auto_install_caddy
		if [[ -z "$auto_install_caddy" ]]; then
			error
		else
			if [[ "$auto_install_caddy" == [Yy] ]]; then
				caddy=true
				install_caddy_info="Abierto"
				echo
				echo
				echo -e "$yellow Configuración automática TLS = $cyan$install_caddy_info$none"
				echo "----------------------------------------------------------------"
				echo
				break
			elif [[ "$auto_install_caddy" == [Nn] ]]; then
				install_caddy_info="cierre"
				echo
				echo
				echo -e "$yellow Configuración automática TLS = $cyan$install_caddy_info$none"
				echo "----------------------------------------------------------------"
				echo
				break
			else
				error
			fi
		fi

	done
}
path_config_ask() {
	echo
	while :; do
		echo -e "Ya sea para habilitar el camuflaje del sitio web y el desvío de ruta [${magenta}Y/N$none]"
		read -p "$(echo -e "(defecto: [${cyan}N$none]):")" path_ask
		[[ -z $path_ask ]] && path_ask="n"

		case $path_ask in
		Y | y)
			path_config
			break
			;;
		N | n)
			echo
			echo
			echo -e "$yellow Enmascaramiento de sitios web y desvío de rutas = $cyan no quiero configurar $none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done
}
path_config() {
	echo
	while :; do
		echo -e "Por favor ingrese el deseado ${magenta} camino utilizado para el desvío $none , por ejemplo /233blog , Entonces solo ingresa 233blog Sólo"
		read -p "$(echo -e "(defecto: [${cyan}233blog$none]):")" path
		[[ -z $path ]] && path="233blog"

		case $path in
		*[/$]*)
			echo
			echo -e " Debido a que este script es demasiado picante, la ruta de derivación no puede contener$red / $noneo$red $ $noneEstos dos símbolos.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow ruta de desvío = ${cyan}/${path}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac
	done
	is_path=true
	proxy_site_config
}
proxy_site_config() {
	echo
	while :; do
		echo -e "por favor escribe ${magenta}un correcto $none ${cyan}URL$none Usado como ${cyan}camuflaje del sitio web$none , por ejemplo https://liyafly.com"
		echo -e "Ejemplo... su nombre de dominio actual es $green$domain$none , La URL falsa es https://liyafly.com"
		echo -e "Luego, cuando abra su nombre de dominio...El contenido mostrado es de https://liyafly.com Contenido"
		echo -e "De hecho, es una anti-generación... Solo entiéndelo..."
		echo -e "Si no puedes disfrazarte con éxito... puedes usar v2ray config Editar URL falsa"
		read -p "$(echo -e "(defecto: [${cyan}https://liyafly.com$none]):")" proxy_site
		[[ -z $proxy_site ]] && proxy_site="https://liyafly.com"

		case $proxy_site in
		*[#$]*)
			echo
			echo -e " Dado que este script es demasiado picante, la URL falsa no puede contener$red # $noneo$red $ $noneEstos dos símbolos.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow URL falsa = ${cyan}${proxy_site}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac
	done
}

blocked_hosts() {
	echo
	while :; do
		echo -e "Ya sea para habilitar el bloqueo de anuncios(afectará el rendimiento) [${magenta}Y/N$none]"
		read -p "$(echo -e "(defecto [${cyan}N$none]):")" blocked_ad
		[[ -z $blocked_ad ]] && blocked_ad="n"

		case $blocked_ad in
		Y | y)
			blocked_ad_info="encender"
			ban_ad=true
			echo
			echo
			echo -e "$yellow bloqueo de anuncios = $cyanencender$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		N | n)
			blocked_ad_info="cierre"
			echo
			echo
			echo -e "$yellow bloqueo de anuncios = $cyan cierre $none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done
}
shadowsocks_config() {

	echo

	while :; do
		echo -e "Ya sea para configurar ${yellow}Shadowsocks${none} [${magenta}Y/N$none]"
		read -p "$(echo -e "(defecto [${cyan}N$none]):") " install_shadowsocks
		[[ -z "$install_shadowsocks" ]] && install_shadowsocks="n"
		if [[ "$install_shadowsocks" == [Yy] ]]; then
			echo
			shadowsocks=true
			shadowsocks_port_config
			break
		elif [[ "$install_shadowsocks" == [Nn] ]]; then
			break
		else
			error
		fi

	done

}

shadowsocks_port_config() {
	local random=$(shuf -i20001-65535 -n1)
	while :; do
		echo -e "por favor escribe "$yellow"Shadowsocks"$none" Puerto ["$magenta"1-65535"$none"]，no puedo y "$yellow"V2Ray"$none" mismo puerto"
		read -p "$(echo -e "(puerto predeterminado: ${cyan}${random}$none):") " ssport
		[ -z "$ssport" ] && ssport=$random
		case $ssport in
		$v2ray_port)
			echo
			echo " No puede ser lo mismo que el port V2Ray...."
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			if [[ $v2ray_transport == [45] ]]; then
				local tls=ture
			fi
			if [[ $tls && $ssport == "80" ]] || [[ $tls && $ssport == "443" ]]; then
				echo
				echo -e "Ya que has elegido "$green"WebSocket + TLS $noneo$green HTTP/2"$none" Protocolo de transferencia."
				echo
				echo -e "así que no hay elección "$magenta"80"$none" o "$magenta"443"$none" Puerto"
				error
			elif [[ $v2ray_dynamic_port_start_input == $ssport || $v2ray_dynamic_port_end_input == $ssport ]]; then
				local multi_port="${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}"
				echo
				echo " Lo sentimos, este puerto entra en conflicto con el puerto dinámico V2Ray, el rango actual del puerto dinámico V2Ray es：$multi_port"
				error
			elif [[ $v2ray_dynamic_port_start_input -lt $ssport && $ssport -le $v2ray_dynamic_port_end_input ]]; then
				local multi_port="${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}"
				echo
				echo " Lo sentimos, este puerto entra en conflicto con el puerto dinámico V2Ray, el rango actual del puerto dinámico V2Ray es：$multi_port"
				error
			else
				echo
				echo
				echo -e "$yellow Shadowsocks Puerto = $cyan$ssport$none"
				echo "----------------------------------------------------------------"
				echo
				break
			fi
			;;
		*)
			error
			;;
		esac

	done

	shadowsocks_password_config
}
shadowsocks_password_config() {

	while :; do
		echo -e "por favor escribe "$yellow"Shadowsocks"$none" clave"
		read -p "$(echo -e "(contraseña predeterminada: ${cyan}233blog.com$none)"): " sspass
		[ -z "$sspass" ] && sspass="233blog.com"
		case $sspass in
		*[/$]*)
			echo
			echo -e " Dado que este script es demasiado picante, la contraseña no puede contener$red / $noneo$red $ $noneEstos dos símbolos.... "
			echo
			error
			;;
		*)
			echo
			echo
			echo -e "$yellow Shadowsocks clave = $cyan$sspass$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		esac

	done

	shadowsocks_ciphers_config
}
shadowsocks_ciphers_config() {

	while :; do
		echo -e "por favor elige "$yellow"Shadowsocks"$none" protocolo de cifrado [${magenta}1-${#ciphers[*]}$none]"
		for ((i = 1; i <= ${#ciphers[*]}; i++)); do
			ciphers_show="${ciphers[$i - 1]}"
			echo
			echo -e "$yellow $i. $none${ciphers_show}"
		done
		echo
		read -p "$(echo -e "(Protocolo de cifrado predeterminado: ${cyan}${ciphers[1]}$none)"):" ssciphers_opt
		[ -z "$ssciphers_opt" ] && ssciphers_opt=2
		case $ssciphers_opt in
		[1-3])
			ssciphers=${ciphers[$ssciphers_opt - 1]}
			echo
			echo
			echo -e "$yellow Shadowsocks protocolo de cifrado = $cyan${ssciphers}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac

	done
	pause
}

install_info() {
	clear
	echo
	echo " ....listo para instalar.. para ver si la configuración es correcta..."
	echo
	echo "---------- Información de instalación -------------"
	echo
	echo -e "$yellow V2Ray Protocolo de transferencia = $cyan${transport[$v2ray_transport - 1]}$none"

	if [[ $v2ray_transport == [45] || $v2ray_transport == 33 ]]; then
		echo
		echo -e "$yellow V2Ray Puerto = $cyan$v2ray_port$none"
		echo
		echo -e "$yellow tu nombre de dominio = $cyan$domain$none"
		echo
		echo -e "$yellow DNS = ${cyan}seguro que ya está analizado$none"
		echo
		echo -e "$yellow Configuración automática TLS = $cyan$install_caddy_info$none"

		if [[ $ban_ad ]]; then
			echo
			echo -e "$yellow bloqueo de anuncios = $cyan$blocked_ad_info$none"
		fi
		if [[ $is_path ]]; then
			echo
			echo -e "$yellow desviación del camino = ${cyan}/${path}$none"
		fi
	elif [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
		echo
		echo -e "$yellow V2Ray Puerto = $cyan$v2ray_port$none"
		echo
		echo -e "$yellow V2Ray rango de puerto dinámico = $cyan${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}$none"

		if [[ $ban_ad ]]; then
			echo
			echo -e "$yellow bloqueo de anuncios = $cyan$blocked_ad_info$none"
		fi
	else
		echo
		echo -e "$yellow V2Ray Puerto = $cyan$v2ray_port$none"

		if [[ $ban_ad ]]; then
			echo
			echo -e "$yellow bloqueo de anuncios = $cyan$blocked_ad_info$none"
		fi
	fi
	if [ $shadowsocks ]; then
		echo
		echo -e "$yellow Shadowsocks Puerto = $cyan$ssport$none"
		echo
		echo -e "$yellow Shadowsocks clave = $cyan$sspass$none"
		echo
		echo -e "$yellow Shadowsocks protocolo de cifrado = $cyan${ssciphers}$none"
	else
		echo
		echo -e "$yellow Ya sea para configurar Shadowsocks = ${cyan}No configurado${none}"
	fi
	echo
	echo "---------- END -------------"
	echo
	pause
	echo
}

domain_check() {
	# if [[ $cmd == "yum" ]]; then
	# 	yum install bind-utils -y
	# else
	# 	$cmd install dnsutils -y
	# fi
	# test_domain=$(dig $domain +short)
	# test_domain=$(ping $domain -c 1 -4 | grep -oE -m1 "([0-9]{1,3}\.){3}[0-9]{1,3}")
	# test_domain=$(wget -qO- --header='accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$domain&type=A" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -1)
	test_domain=$(curl -sH 'accept: application/dns-json' "https://cloudflare-dns.com/dns-query?name=$domain&type=A" | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}" | head -1)
	if [[ $test_domain != $ip ]]; then
		echo
		echo -e "$red Detectando errores de resolución de nombres de dominio....$none"
		echo
		echo -e " tu nombre de dominio: $yellow$domain$none no resuelto: $cyan$ip$none"
		echo
		echo -e " Su nombre de dominio actualmente se resuelve en: $cyan$test_domain$none"
		echo
		echo "Nota... si su nombre de dominio está utilizando Cloudflare Analizando palabras.. en Status haga clic en ese ícono allí ... hágalo gris"
		echo
		exit 1
	fi
}

install_caddy() {
	# download caddy file then install
	_load download-caddy.sh
	_download_caddy_file
	_install_caddy_service
	caddy_config

}
caddy_config() {
	# local email=$(shuf -i1-10000000000 -n1)
	_load caddy-config.sh

	# systemctl restart caddy
	do_service restart caddy
}

install_v2ray() {
	$cmd update -y
	if [[ $cmd == "apt-get" ]]; then
		$cmd install -y lrzsz git zip unzip curl wget qrencode libcap2-bin dbus
	else
		# $cmd install -y lrzsz git zip unzip curl wget qrencode libcap iptables-services
		$cmd install -y lrzsz git zip unzip curl wget qrencode libcap
	fi
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	[ -d /etc/v2ray ] && rm -rf /etc/v2ray
	# date -s "$(curl -sI g.cn | grep Date | cut -d' ' -f3-6)Z"
	_sys_timezone
	_sys_time

	if [[ $local_install ]]; then
		if [[ ! -d $(pwd)/config ]]; then
			echo
			echo -e "$red Ups... la instalación falló...$none"
			echo
			echo -e " Asegúrese de tener el script de administración y el script de instalación con un solo clic de V2Ray cargados en 233v2.com al actual ${green}$(pwd) $noneBajo contenido"
			echo
			exit 1
		fi
		mkdir -p /etc/v2ray/233boy/v2ray
		cp -rf $(pwd)/* /etc/v2ray/233boy/v2ray
	else
		pushd /tmp
		git clone https://github.com/233boy/v2ray -b "$_gitbranch" /etc/v2ray/233boy/v2ray --depth=1
		popd

	fi

	if [[ ! -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo -e "$red Vaya... Error al clonar el repositorio de secuencias de comandos...$none"
		echo
		echo -e " Recordatorio... Intente instalar Git usted mismo: ${green}$cmd install -y git $none Instalar este script más tarde"
		echo
		exit 1
	fi

	# download v2ray file then install
	_load download-v2ray.sh
	_download_v2ray_file
	_install_v2ray_service
	_mkdir_dir
}

config() {
	cp -f /etc/v2ray/233boy/v2ray/config/backup.conf $backup
	cp -f /etc/v2ray/233boy/v2ray/v2ray.sh $_v2ray_sh
	chmod +x $_v2ray_sh

	v2ray_id=$uuid
	alterId=0
	ban_bt=true
	if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
		v2ray_dynamicPort_start=${v2ray_dynamic_port_start_input}
		v2ray_dynamicPort_end=${v2ray_dynamic_port_end_input}
	fi
	_load config.sh

	# if [[ $cmd == "apt-get" ]]; then
	# 	cat >/etc/network/if-pre-up.d/iptables <<-EOF
	# 		#!/bin/sh
	# 		/sbin/iptables-restore < /etc/iptables.rules.v4
	# 		/sbin/ip6tables-restore < /etc/iptables.rules.v6
	# 	EOF
	# 	chmod +x /etc/network/if-pre-up.d/iptables
	# 	# else
	# 	# 	[ $(pgrep "firewall") ] && systemctl stop firewalld
	# 	# 	systemctl mask firewalld
	# 	# 	systemctl disable firewalld
	# 	# 	systemctl enable iptables
	# 	# 	systemctl enable ip6tables
	# 	# 	systemctl start iptables
	# 	# 	systemctl start ip6tables
	# fi

	# systemctl restart v2ray
	do_service restart v2ray
	backup_config

}

backup_config() {
	sed -i "18s/=1/=$v2ray_transport/; 21s/=2333/=$v2ray_port/; 24s/=$old_id/=$uuid/" $backup
	if [[ $v2ray_transport -ge 18 && $v2ray_transport -ne 33 ]]; then
		sed -i "30s/=10000/=$v2ray_dynamic_port_start_input/; 33s/=20000/=$v2ray_dynamic_port_end_input/" $backup
	fi
	if [[ $shadowsocks ]]; then
		sed -i "42s/=/=true/; 45s/=6666/=$ssport/; 48s/=233blog.com/=$sspass/; 51s/=chacha20-ietf/=$ssciphers/" $backup
	fi
	[[ $v2ray_transport == [45] || $v2ray_transport == 33 ]] && sed -i "36s/=233blog.com/=$domain/" $backup
	[[ $caddy ]] && sed -i "39s/=/=true/" $backup
	[[ $ban_ad ]] && sed -i "54s/=/=true/" $backup
	if [[ $is_path ]]; then
		sed -i "57s/=/=true/; 60s/=233blog/=$path/" $backup
		sed -i "63s#=https://liyafly.com#=$proxy_site#" $backup
	fi
}

get_ip() {
	ip=$(curl -s https://ipinfo.io/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.ip.sb/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.ipify.org)
	[[ -z $ip ]] && ip=$(curl -s https://ip.seeip.org)
	[[ -z $ip ]] && ip=$(curl -s https://ifconfig.co/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && ip=$(curl -s icanhazip.com)
	[[ -z $ip ]] && ip=$(curl -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && echo -e "\n$red ¡Tira esta basura de pollito!$none\n" && exit
}

error() {

	echo -e "\n$red ¡error de entrada!$none\n"

}

pause() {

	read -rsp "$(echo -e "de acuerdo a $green Enter ingresar $none Continuar....o pulsar $red Ctrl + C $none Cancelar.")" -d $'\n'
	echo
}
do_service() {
	if [[ $systemd ]]; then
		systemctl $1 $2
	else
		service $2 $1
	fi
}
show_config_info() {
	clear
	_load v2ray-info.sh
	_v2_args
	_v2_info
	_load ss-info.sh

}

install() {
	if [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f $backup && -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo " Grandote... ya instalaste V2Ray... no es necesario reinstalarlo"
		echo
		echo -e " $yellow输入 ${cyan}v2ray${none} $yellow即可管理 V2Ray${none}"
		echo
		exit 1
	elif [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f /etc/v2ray/233blog_v2ray_backup.txt && -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo "  Si necesita continuar con la instalación... primero desinstale la versión anterior"
		echo
		echo -e " $yellowingresar ${cyan}v2ray uninstall${none} $yellowdesinstalar${none}"
		echo
		exit 1
	fi
	v2ray_config
	blocked_hosts
	shadowsocks_config
	install_info
	# [[ $caddy ]] && domain_check
	install_v2ray
	if [[ $caddy || $v2ray_port == "80" ]]; then
		if [[ $cmd == "yum" ]]; then
			[[ $(pgrep "httpd") ]] && systemctl stop httpd
			[[ $(command -v httpd) ]] && yum remove httpd -y
		else
			[[ $(pgrep "apache2") ]] && service apache2 stop
			[[ $(command -v apache2) ]] && apt-get remove apache2* -y
		fi
	fi
	[[ $caddy ]] && install_caddy

	## bbr
	# _load bbr.sh
	# _try_enable_bbr

	get_ip
	config
	show_config_info
}
uninstall() {

	if [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f $backup && -d /etc/v2ray/233boy/v2ray ]]; then
		. $backup
		if [[ $mark ]]; then
			_load uninstall.sh
		else
			echo
			echo -e " $yellowingresar ${cyan}v2ray uninstall${none} $yellowdesinstalar${none}"
			echo
		fi

	elif [[ -f /usr/bin/v2ray/v2ray && -f /etc/v2ray/config.json ]] && [[ -f /etc/v2ray/233blog_v2ray_backup.txt && -d /etc/v2ray/233boy/v2ray ]]; then
		echo
		echo -e " $yellowingresar ${cyan}v2ray uninstall${none} $yellowdesinstalar${none}"
		echo
	else
		echo -e "
		$red Tetonas... pareces que tienes pelo instalado V2Ray ....desinstalar una polla...$none

		Observaciones...Solo admite la desinstalación usandome (233v2.com) que proporcionó V2Ray Script de instalación con un solo clic
		" && exit 1
	fi

}

args=$1
_gitbranch=$2
[ -z $1 ] && args="online"
case $args in
online)
	#hello world
	[[ -z $_gitbranch ]] && _gitbranch="master"
	;;
local)
	local_install=true
	;;
*)
	echo
	echo -e " el parámetro que ingresó <$red $args $none> ...que diablos es esto...el script no lo reconoce wow"
	echo
	echo -e " Este script de pollo picante solo admite entrada$green local / online $noneparámetro"
	echo
	echo -e " ingresar$yellow local $nonees decir, usando una instalación local"
	echo
	echo -e " ingresar$yellow online $nonees decir, usar la instalación en línea (predeterminado)"
	echo
	exit 1
	;;
esac

clear
while :; do
	echo
	echo "........... V2Ray Script de instalación con un solo clic & Administrar guiones by 233v2.com .........."
	echo
	echo "Descripción de la ayuda: https://233v2.com/post/1/"
	echo
	echo "Tutorial de construcción: https://233v2.com/post/2/"
	echo
	echo " 1. Instalar"
	echo
	echo " 2. desinstalar"
	echo
	if [[ $local_install ]]; then
		echo -e "$yellow amables consejos.. La instalación local está habilitada ..$none"
		echo
	fi
	read -p "$(echo -e "por favor elige [${magenta}1-2$none]:")" choose
	case $choose in
	1)
		install
		break
		;;
	2)
		uninstall
		break
		;;
	*)
		error
		;;
	esac
done
