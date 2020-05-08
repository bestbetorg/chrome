FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG='en_GB.UTF-8' LANGUAGE='en_GB:en' LC_ALL='en_GB.UTF-8'
ENV TZ Europe/London

ENV VNC_SCREEN_SIZE 1366x768

COPY copyables /

RUN echo $TZ > /etc/timezone

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
        locales \
        tzdata \
	gnupg2 \
        fonts-noto-cjk \
	supervisor \
        xvfb \
	x11vnc \
	fluxbox \
	eterm

RUN echo en_GB.UTF-8 UTF-8 >> /etc/locale.gen && locale-gen

RUN rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

ADD https://dl.google.com/linux/linux_signing_key.pub \
	https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
	/tmp/

RUN apt-key add /tmp/linux_signing_key.pub \
	&& apt-get install -y --no-install-recommends \
        /tmp/google-chrome-stable_current_amd64.deb

RUN wget https://deb.nodesource.com/setup_12.x -qO- | bash
RUN apt-get install -y --no-install-recommends nodejs

RUN apt-get clean \
	&& rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/* \
        && useradd -m chrome \
	&& usermod -s /bin/bash chrome \
        && mkdir -p /home/chrome/.config \
	&& mkdir -p /home/chrome/.fluxbox \
	&& echo ' \n\
		session.screen0.toolbar.visible:        false\n\
		session.screen0.fullMaximization:       true\n\
		session.screen0.maxDisableResize:       true\n\
		session.screen0.maxDisableMove: true\n\
		session.screen0.defaultDeco:    NONE\n\
	' >> /home/chrome/.fluxbox/init \
	&& chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

VOLUME ["/home/chrome"]

EXPOSE 5900

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord"]
