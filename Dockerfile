FROM armv7/armhf-debian
MAINTAINER Michael Haas <haas@computerlinguist.org>
ENV GPIO_PON=265 GPIO_DATA=266 GPIO_DATA_INVERT=true DEBUG=false
RUN apt-get update && apt-get install -y git ca-certificates gcc make
USER nobody
# use my repo instead of vogelchr's to get low-pass filtering of erratic pulses
RUN cd /tmp/ && git clone https://github.com/mhaas/radioclkd2.git && \
    cd radioclkd2 && ./configure && make
USER root
RUN cd /tmp/radioclkd2 && make install
COPY radioclkd2-wrapper.sh /usr/local/bin/radioclkd2-wrapper.sh
CMD ["/usr/local/bin/radioclkd2-wrapper.sh"]
