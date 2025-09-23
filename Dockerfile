# ==========================================
# Stage 1: Build the Java application with Maven
# ==========================================
FROM maven:3.9.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml and download dependencies first (better caching)
COPY . .
RUN mvn dependency:go-offline -B

# Copy the source and build
COPY src ./src
RUN mvn clean package -DskipTests

# ==========================================
# Stage 2: Run the application
# ==========================================
FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

# Copy only the JAR file from build stage
COPY --from=build /app/target/*.jar app.jar
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
