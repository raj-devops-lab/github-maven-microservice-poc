# FROM eclipse-temurin:17-jdk

# # Create non-root user
# RUN groupadd -g 1001 -r platform_user && \
#     useradd -r -u 1001 -g platform_user platform_user

# RUN mkdir /platform && chown -R platform_user:platform_user /platform

# # Copy the built jar into the container as app.jar
# # COPY --chown=platform_user:platform_user target/*.jar /platform/app.jar
# # COPY --chown=platform_user:platform_user entrypoint.sh /platform/entrypoint.sh

# RUN chmod +x /platform/entrypoint.sh

# USER platform_user
# WORKDIR /platform

# ENTRYPOINT ["/platform/entrypoint.sh"]


FROM eclipse-temurin:17-jdk

# Set working directory
WORKDIR /platform

# Copy built jar and entrypoint with correct permissions
COPY target/*.jar /platform/app.jar
COPY --chmod=755 entrypoint.sh /platform/entrypoint.sh

# Run the service
ENTRYPOINT ["/platform/entrypoint.sh"]

