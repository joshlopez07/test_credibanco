# Utiliza una imagen base de Maven
FROM maven:3.8.4-openjdk-11 AS builder

# Establece el directorio de trabajo dentro de la imagen
WORKDIR /usr/src/app

# Copia el archivo pom.xml para descargar las dependencias
COPY pom.xml .

# Descarga las dependencias del proyecto
RUN mvn dependency:go-offline

# Copia el resto del código fuente al directorio de trabajo
COPY src ./src

# Compila la aplicación
RUN mvn package

# Segunda etapa de la construcción de la imagen
FROM openjdk:11-jre-slim

# Establece el directorio de trabajo dentro de la nueva imagen
WORKDIR /usr/src/app

# Copia solo los archivos necesarios desde la primera imagen
COPY --from=builder /usr/src/app/target/*.jar app.jar

# Expone el puerto en el que la aplicación se ejecutará
EXPOSE 8080

# Comando para ejecutar la aplicación al iniciar el contenedor
CMD ["java", "-jar", "app.jar"]
