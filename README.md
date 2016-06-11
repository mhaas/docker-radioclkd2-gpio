# Radioclkd2 with GPIO support for ARM-based single board computers #

This docker image is intended to provide an easy way to run a Pollin "DCF1" DCF77 receiver on an
Sunxi A20 ARM-based single board computer. The image is running Christian Vogel's version of radioclkd2
with GPIO support. See [his blog](http://vogelchr.blogspot.de/2013/09/dcf77-via-gpio-on-raspberry-pi-patched.html)
and the [GitHub repo](https://github.com/vogelchr/radioclkd2).

I developed this image on my OlinuXino-A20-Lime2 running Debian Wheezy. I use the "DCF1" DCF77 receiver
which can be obtained from Pollin.

## Connecting Pollin's DCF1 to the OlinuXino-A20-Lime2 ##

First things first: you will need to use GPIO pins with interrupt support. Not all
pins support interrupts. You can easily find out if a given pin `$PIN` supports interrupts
by exporting it via `echo $PIN > /sys/class/gpio/export` and then checking for the presence
of `/sys/class/gpio/gpio$PIN/edge`.

Alternatively, consult the file drivers/pinctrl/sunxi/pinctrl-sun7i-a20.c of your
(mainline) kernel. Pins supporting interrupts will use the `SUNXI_FUNCTION_IRQ` macro. For example, pin I9 uses
that macro. To get the final number of the pin, look up the base for the pin bank inside drivers/pinctrl/sunxi/pinctrl-sunxi.h.
Here, `PI_BASE` is defined to be 256. The final pin number of pin I9 is then 264, which we can use to enable the pin
via export as described above.

Coincidentally, pins I9 (265) and I10 (266) are what I use in my setup. These values are reflected
in the ENV variables inside the `Dockerfile`. Note that finding out these things was quite a pain.
I recommend sticking to my setup including the pin usage as close as possible.

Another important thing is the kernel version you are using. I have no experience using the
original allwinner kernels provided e.g. by the Olimex images. I use a mainline Debian Wheezy
along with a 4.6 mainline kernel obtained from kernel.org. It is quite important to use a recent
kernel which has [Henry Paulissen's GPIO IRQ](https://groups.google.com/d/topic/linux-sunxi/2a1p-zg24RQ/discussion).

Finally, you will need a way to connect the receiver to the OlinuXino. I use the 
[A20-OLinuXino-LIME2-UEXT breakout board](https://www.olimex.com/Products/OLinuXino/A20/A20-OLinuXino-LIME2-UEXT/open-source-hardware)
connected to the GPIO-3 header on the OlinuXino itself. Refer to
[the schematic](https://www.olimex.com/Products/OLinuXino/A20/A20-OLinuXino-LIME2-UEXT/resources/A20-OLinuXino-Lime2-UEXT_sch.pdf)
to find the proper pin mapping. For GPIO-3, the exposed pins of the A20 SOC
are listed in third column inside the schematic.


### Pin mapping ###

Pin mapping from DCF1 to the breakout connected to GPIO-3:

PON  -> 27 (PI9)
DATA -> 29 (PI10)
GND  -> 2 (GND)
VCC  -> 3 (3.3V)

Do not use 5V for the DCF1! It will appear to work, but the data won't be decoded.

The DCF1 requires a special power-on sequence via its PON pin. This is reflected in the
`radioclkd2-wrapper.sh`'script. Chances are that your own DCF77 receiver will work
without such a special sequence and you will be able to use a single pin for DATA only.
In this case, feel free to delete the related
code in the script. 

## Environment Variables ##

The docker image supports three environment variables:

GPIO\_PON: the GPIO pin where the power-on (PON) pin is connected
GPIO\_DATA: the GPIO pin where the DATA pin is connected.
GPIO\_DATA\_INVERT: flag indicating the ':-DCD' should be appended to radioclkd2 device string. Needs to be 'true' for the DCF1.
DEBUG: flag enabling radioclkd2 verbose output, disables SHM for NTPD!

## Low-pass filter / radioclkd2 patches ##

During my testing, I noticed that [dcf77pi](https://github.com/rene0/dcf77pi) worked flawlessly
while radioclkd2 would complain about invalid (too short) pulse lengths. With some debugging `printf`s,
I found that indeed the interrupt would trigger intermittently, causing radioclkd2 to read a pulse that's
too short. I added some code to act [as a low-pass filter](https://github.com/vogelchr/radioclkd2/pull/2).

I don't know why this issue originally occurs. It may be improper power supply, too much noise on the data
lines (i.e. needs ferrit shield),just poor wiring or perhaps a flake in the sun7i IRQ handling.
Since I'm a software guy, I decided to fix it in radioclkd2. The greater internet knows some things you can
try. There's a German guide at [netzmafia.de showing some sort of amplifier for the weak data output](http://www.netzmafia.de/skripten/hardware/RasPi/Projekt-DCF77/)
and the (German) forums at [mikrocontroller.net](http:((www.mikrocontroller.net) also have many insights
on the module.

## Automatic GPIO setup ##

`radioclkd2-wrapper.sh` automatically sets up the GPIO pins and performs the
power-up sequence for the DCF1.

## Running a container ##

See `run.sh`.

Note that I'm not passing any ENV variables there as the defaults in the Dockerfile
match my setup.

## TODO ##

- Drop privileges (user, linux capabilities)
