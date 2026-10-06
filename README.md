# Práctica Apache en AWS: SSL con Let's Encrypt

Configuración de un servidor Apache desplegado en AWS con HTTPS, certificado
gratuito de Let's Encrypt, redirección automática desde HTTP y protección de
un directorio mediante `.htaccess`.

## Objetivos

- Publicar el sitio mediante Apache en una instancia EC2.
- Emitir y configurar un certificado SSL con Certbot.
- Redirigir el tráfico del puerto 80 al puerto 443.
- Configurar una página personalizada para los errores 404.
- Redirigir la ruta `/fp` a `https://www.todofp.es`.
- Proteger un directorio privado mediante autenticación básica de Apache.

## Requisitos previos

- Una instancia EC2 con Ubuntu y Apache instalado.
- Un nombre de dominio o subdominio apuntando a la IP pública de la instancia.
- Reglas del grupo de seguridad de AWS para permitir:
  - TCP `22` para SSH.
  - TCP `80` para HTTP y para la validación de Let's Encrypt.
  - TCP `443` para HTTPS.
- Permisos para ejecutar comandos con `sudo`.

El dominio usado en esta práctica es `ar-servidor.ddns.net`. Si se utiliza otro,
deben actualizarse el archivo `.env` y las directivas `ServerName` de Apache.

## Estructura del repositorio

```text
.
├── 000-default.conf
├── 000-default-le-ssl.conf
├── .env.example
├── .gitignore
├── README.md
├── capturas/
│   ├── 01_nslookup.png
│   ├── 02_certificado_letsencrypt.png
│   ├── 03_pagina_index.png
│   ├── 04_error_404.png
│   ├── 05_analisis_logs.png
│   └── 06_htaccess_privado.png
└── scripts/
	 └── setup_ssl.sh
```

- `scripts/setup_ssl.sh`: instala Certbot y solicita el certificado de forma
  no interactiva. También configura la redirección a HTTPS.
- `000-default.conf`: virtual host HTTP en el puerto 80, con redirección a
  HTTPS, error 404 personalizado, logs y redirección de `/fp`.
- `000-default-le-ssl.conf`: virtual host HTTPS en el puerto 443 generado por
  Certbot, incluyendo las rutas del certificado.
- `.env.example`: plantilla de las variables necesarias. No contiene secretos.
- `.gitignore`: evita versionar `.env` y archivos `.pem`.
- `capturas/`: evidencias del funcionamiento de la práctica.

## Instalación y configuración

1. Conectarse a la instancia por SSH y comprobar que Apache responde:

	```bash
	sudo systemctl status apache2
	```

2. Clonar o copiar este repositorio en el servidor y entrar en su directorio:

	```bash
	cd practica-apache-aws
	```

3. Crear el archivo `.env` a partir de la plantilla y editar sus valores:

	```bash
	cp .env.example .env
	nano .env
	```

	El archivo debe contener únicamente las variables requeridas por el script:

	```dotenv
	DOMAIN="ar-servidor.ddns.net"
	EMAIL="tu_email@ejemplo.com"
	```

4. Dar permisos de ejecución al script y ejecutarlo desde la raíz del proyecto:

	```bash
	chmod +x scripts/setup_ssl.sh
	./scripts/setup_ssl.sh
	```

	El script instala `certbot` y `python3-certbot-apache`, solicita el
	certificado con aceptación de los términos y configura la redirección
	automática hacia HTTPS.

5. Validar la configuración y recargar Apache:

	```bash
	sudo apache2ctl configtest
	sudo systemctl reload apache2
	```

## Configuración adicional

El documento `000-default.conf` define el `DocumentRoot` en `/var/www/html`

- `ErrorDocument 404 /404.html` para mostrar una página 404 personalizada.
- `Redirect 301 /fp https://www.todofp.es` para la ruta `/fp`.
- La redirección permanente de todas las peticiones HTTP del dominio a HTTPS.

El archivo de credenciales debe crearse fuera del directorio público:

```bash
sudo htpasswd -c /etc/apache2/.htpasswd usuario
```

## Evidencias

1. `01_nslookup.png`: resolución DNS del dominio.
2. `02_certificado_letsencrypt.png`: certificado emitido por Let's Encrypt.
3. `03_pagina_index.png`: página principal servida mediante HTTPS.
4. `04_error_404.png`: respuesta de la página personalizada para una ruta inexistente.
5. `05_analisis_logs.png`: registros de acceso y errores de Apache.
6. `06_htaccess_privado.png`: autenticación del directorio protegido con `.htaccess`.

## Seguridad

- No subir `.env`, contraseñas ni claves privadas al repositorio.
- Mantener abiertos en AWS únicamente los puertos necesarios.
- Usar siempre HTTPS para acceder a la aplicación.
- Sustituir los valores de ejemplo del dominio y del correo antes de ejecutar el script.