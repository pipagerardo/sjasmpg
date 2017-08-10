---------------------------------------------------------------
LINUX / UBUNTU / WINDOWS / MAC:
-------------------------------

GNU GCC Compiler

Linker:
	-static-libgcc		// Librería gcc estática. No usar en MAC
	-static-libstdc++	// Librería std c++ estática. No usar en MAC
	-s			// Strip all symbols from binary (minimizes size) No usar en MAC

Compiler:
	-Wall			// Enable all common compiler warnings
	-Wextra			// Enable extra compiler warnings
	-O3			// Optimize fully (for speed)

Defines:
	-DWINDOWS		// Windows
	-DLINUX			// Linux
	-DAPPLE			// MAC, similar a Linux
	-DSPANISH		// Idioma en Español, Inglés por defecto.
	-DLANGUAGE_UTF8		// El Español en Linux usa UTF8

Targets:
	windows_esp	-DWINDOWS -DSPANISH
	windows_eng	-DWINDOWS
	linux_esp	-DLINUX -DSPANISH -DLANGUAGE_UTF8
	linux_eng	-DLINUX 
	mac_esp		-DAPPLE -DSPANISH -DLANGUAGE_UTF8
	mac_eng		-DAPPLE
---------------------------------------------------------------
Limpiar la carpeta boot si es necesario (Sólo linux):
-----------------------------------------------------

sudo su

apt-get autoclean
apt-get autoremove

dpkg --get-selections | grep linux-image
apt purge elpaqueteviejo1 elpaqueteviejo2 ...

---------------------------------------------------------------
Instalar paquetes de idioma Español (Sólo linux):
-------------------------------------------------

sudo apt-get install language-pack-es

sudo apt-get install language-pack-es-base

---------------------------------------------------------------
Instalar GNU GCC (Sólo linux):
------------------------------
En Linux si es que no lo tienes instalado!

---------------------------------------------------------------
Instalar Codeblocks:
--------------------
En Windows bajarse la versión con el compilador incluido.
http://www.codeblocks.org/

---------------------------------------------------------------
Abrir Proyecto Codeblocks y Compilar:
-------------------------------------

---------------------------------------------------------------
Este código ha sido modificado por pipagerado sobre el código
original Sjasm v42c de Sjoerd Mastijn - www.xl2s.tk
---------------------------------------------------------------
