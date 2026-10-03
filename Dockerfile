# Position simulator (Spring Boot 2.7, Java 17).
# The doc's FROM openjdk:8u131-jre cannot run this Java 17 jar, and the author's
# amazoncorretto "al2022-RC" base is a preview image, so we use Eclipse Temurin 17.
# The jar is built by Maven in the Jenkins "Build" stage before docker build runs.
FROM eclipse-temurin:17-jre

COPY target/positionsimulator-0.0.1-SNAPSHOT.jar /app/webapp.jar

CMD ["java", "-jar", "/app/webapp.jar"]
