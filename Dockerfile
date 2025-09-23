FROM openjdk:17

RUN groupadd -g 1001 -r platform_user &&  useradd -r -u  1001 -g platform_user platform_user

RUN mkdir /platform && chown -R platform_user  /platform

ADD --chown=platform_user:platform_user /target/*.jar /platform

COPY --chown-platform_user:platform_user entrypoint.sh /platformentrypoint.sh

RUN ["chmod", "+x", "/platform/entrypoint.sh"]

USER platform_user

WORKDIR platform_user

ENTRYPOINT ["/platform/entrypoint.sh"]