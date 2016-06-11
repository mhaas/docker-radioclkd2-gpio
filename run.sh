# --restart=always enables autostart on boot:
# https://serverfault.com/questions/633067/how-do-i-auto-start-docker-containers-at-system-boot
docker run --name=radioclkd2-gpio --privileged -v /sys/class/gpio:/sys/class/gpio/:rw   mhaas/radioclkd2-gpio:latest
