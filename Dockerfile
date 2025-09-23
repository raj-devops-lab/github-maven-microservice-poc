FROM eclipse-temurin:17-jdk-jammy

# Create non-root user
RUN groupadd -g 1001 -r platform_user && \
    useradd -r -u 1001 -g platform_user platform_user

# App directory
RUN mkdir /platform && chown -R platform_user:platform_user /platform
WORKDIR /platform

# Copy JAR
ARG JAR_FILE=target/*.jar
COPY --chown=platform_user:platform_user ${JAR_FILE} /platform/app.jar

# Copy entrypoint
COPY entrypoint.sh /platform/entrypoint.sh
RUN chmod +x /platform/entrypoint.sh && \
    chown platform_user:platform_user /platform/entrypoint.sh

# Run as non-root
USER platform_user

ENTRYPOINT ["/platform/entrypoint.sh"]
