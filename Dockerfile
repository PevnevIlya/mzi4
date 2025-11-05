# --- Этап 1: Сборка JAR с Maven 3.9 + JDK 21 ---
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Копируем pom.xml и зависимости (для кэша слоёв)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Копируем исходники
COPY src ./src

# Собираем JAR (пропускаем тесты)
RUN mvn clean package -DskipTests -B

# --- Этап 2: Запуск с JRE 21 (маленький образ) ---
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Копируем JAR из этапа сборки
COPY --from=build /app/target/*.jar app.jar

# Открываем порт 8080 (для Spring Boot)
EXPOSE 8080

# Запускаем приложение
ENTRYPOINT ["java", "-jar", "app.jar"]