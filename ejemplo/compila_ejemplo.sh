#!/bin/bash
bin/./pletter_linux_esp src/snd/SG_boot1.pt3
bin/./png2msx_linux_esp src/grf/phantis.png -c -t
.././sjasmpg_linux_esp -s src/ejemplo.asm ejemplo.rom
