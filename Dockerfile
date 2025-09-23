FROM eclipse-temurin:17-jdk

# Create non-root user
RUN groupadd -g 1001 -r platform_user && \
    useradd -r -u 1001 -g platform_user platform_user

RUN mkdir /platform && chown -R platform_user:platform_user /platform

# Copy the built jar into the container as app.jar
COPY --chown=platform_user:platform_user target/*.jar /platform/app.jar
COPY --chown=platform_user:platform_user entrypoint.sh /platform/entrypoint.sh

RUN chmod +x /platform/entrypoint.sh

USER platform_user
WORKDIR /platform

ENTRYPOINT ["/platform/entrypoint.sh"]
