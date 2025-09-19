Estructura del repositorio

farmactrl-automation/
├─ .github/workflows/ci.yml          
├─ .gitignore
├─ pom.
├─ mvnw / mvnw.cmd / .mvn/           
├─ src/
│  ├─ main/java/cl/iplacex/farmactrl/App.java
│  └─ test/java/cl/iplacex/farmactrl/SampleUnitTest.java
└─ target/      

Ejercicio 1 – Configuración inicial de entorno y dependencias
Flujo de ramas (Trunk-Based)
•	Rama principal: main
•	Trabajo diario en ramas cortas: feature/<tema>, bugfix/<id>
•	Integración vía Pull Request con checks del pipeline.
Con bash
git checkout -b feature/escaneo-codigos
git commit -m "feat: escaneo de códigos de barra"
git push -u origin feature/escaneo-codigos
pom.xml (Java 21 + JUnit 5)
•	Compilación con Java 21 (maven-compiler-plugin)
•	JUnit 5 (jupiter) para pruebas
•	Surefire para ejecutar tests
•	(Opcional) Surefire Report para HTML, Si luego quisiéramos agregar Selenium, podríamos sumar las dependencias y un test de integración con navegador.
Ejercicio 2 – Estrategias de pruebas e Integración Continua
Pipeline de CI (GitHub Actions)
Ruta: .github/workflows/ci.yml
Esto en yaml
name: CI Java 21

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
          cache: maven

      # Build + Tests (JUnit 5) y guardamos un log
      - name: Build & Test
        run: ./mvnw -B -ntp clean verify | tee build.log

      # (Opcional para proximas actualizaciones Selenium) Reporte HTML de Surefire
      - name: Generate Surefire HTML report
        run: ./mvnw -B -ntp surefire-report:report

      # Subimos evidencias como artefactos
      - name: Upload test artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: maven-test-reports
          path: |
            build.log
            **/target/surefire-reports/**
            **/target/site/surefire-report.html
          if-no-files-found: warn

Tipos de pruebas
•	Unitarias: src/test/java/... (JUnit 5).
•	Integración (opcional aquí): puedes agregar una clase con @Tag("integration") y ejecutarla en otro job o fase.
Evidencias en CI
En cada ejecución del workflow:
•	Artefacto maven-test-reports con:
o	build.log
o	target/surefire-reports/*.xml|*.txt
o	target/site/surefire-report.html (si habilitado)
•	Capturas de los procesos para incorporar en la entrega: pantalla del job Build & Test con BUILD SUCCESS y resumen de tests.
Ejercicio 3 – Deployment Pipeline y aseguramiento de calidad 
Este repositorio incluye el CI. A continuación, una plantilla para el deployment pipeline (integrado como .github/workflows/deploy.yml o usa Jenkins/GitLab si prefieres). Se integra:
•	Acceptance Tests Gate (tests BDD/E2E rápidos en staging)
•	Rollback automático ante fallas
•	Estrategia Blue-Green o Canary (según infraestructura)
Para el yaml

name: Deploy (Staging + Acceptance Gate)

on:
  workflow_dispatch:

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
          cache: maven

      - name: Build artifact
        run: ./mvnw -B -ntp -DskipTests package

      # Ejemplo: levantar entorno efímero (Docker Compose)
      - name: Start staging (docker-compose)
        run: docker compose -f infra/docker-compose.staging.yml up -d

      # Acceptance Gate (reemplaza por la suite BDD/E2E)
      - name: Acceptance tests
        run: ./mvnw -B -ntp verify -P acceptance

      # Si falla el gate, ejecuta rollback
      - name: Rollback
        if: failure()
        run: ./scripts/rollback.sh

Evidencias de despliegue/rollback
Incluye en la entrega:
•	Logs del job de deploy
•	Captura de Acceptance Gate (pasó/falló)
•	Evidencia del rollback o del switch Blue-Green/Canary
NO OLVIDAR CÓMO EJECUTAR LOCALMENTE
Requisitos
•	Java 21
•	Opcional Maven instalado — aunque usamos Maven Wrapper (./mvnw)
Build + tests + log
Git Bash / WSL
./mvnw -B -ntp clean verify | tee build.log

Ejercicio 3 – Deployment Pipeline y aseguramiento de calidad
Este repo trae el CI. Aquí con una plantilla para un deployment pipeline (se crea .github/workflows/deploy.yml o usar Jenkins/GitLab si prefieres):
name: Deploy (Staging + Acceptance Gate)

on:
  workflow_dispatch:

jobs:
  deploy-staging:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '21'
          cache: maven

      - name: Build artifact
        run: ./mvnw -B -ntp -DskipTests package

      # (Ejemplo) levantar entorno efímero
      - name: Start staging (docker-compose)
        run: docker compose -f infra/docker-compose.staging.yml up -d

      # Acceptance Gate (reemplazar por tu suite BDD/E2E/tag @acceptance)
      - name: Acceptance tests
        run: ./mvnw -B -ntp verify -P acceptance

      # Si falla el gate => rollback
      - name: Rollback
        if: failure()
        run: ./scripts/rollback.sh
Estrategias de despliegue
•	Rollback automático: script en scripts/rollback.sh que vuelve al artefacto estable.
•	Blue-Green: mantener dos entornos idénticos y “switch” de tráfico.
•	Canary: liberar a un % de tráfico incremental con métricas y health checks.
Evidencias de despliegue/rollback
Adjuntar logs del job de deploy, captura del Acceptance Gate (pass/fail) y evidencia del rollback o del switch Blue-Green/Canary.
Cómo ejecutar todo localmente con log
./mvnw -B -ntp clean verify | tee build.log



