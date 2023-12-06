pipeline {
    agent any

    environment {
        // Define las variables de entorno necesarias
        GITHUB_REPO = 'https://github.com/joshlopez07/test_credibanco.git'
        DOCKERHUB_REPO = 'joshlopez07/test-credibanco'
        SONAR_TOKEN = '44e6312071241f6f998e64469a745e5ff14fae45'
    }

    stages {
        stage('Clonar Repositorio') {
            steps {
                // Clonar el repositorio de GitHub
                script {
                    git branch: 'develop', url: "${GITHUB_REPO}", credentialsId: 'github_credentials'

                }
                sh "ls -la"
            }
        }
        stage('Build con Maven') {
            steps {
                // Realizar build con Maven
                dir("gs-spring-boot-complete") {
                    script {
                        sh 'mvn clean install'
                    }
                    sh "ls -la"
                }
            }
        }
      
        stage('Ejecutar Pruebas Unitarias') {
            steps {
                // Ejecutar pruebas unitarias con JUnit
                dir("gs-spring-boot-complete") {
                    script {
                        sh 'mvn test' // Asegúrate de tener configurado Maven en tu proyecto
                    }
                    sh "ls -la"
                }
            }
        }

        stage('Analizar Código con SonarQube') {
            steps {
                // Analizar código con SonarQube
                    script {
                        withSonarQubeEnv('SonarCloud') {
                            //sh 'mvn verify sonar:sonarr' // Asegúrate de tener configurado SonarQube en tu proyecto
                            sh 'mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=joshlopez07_test_credibanco'
                            //sh './gradlew sonar'
                        }
                    }
                    sh "ls -la"
            }
        }

        stage('Construir Imagen Docker') {
            steps {
                // Construir la imagen Docker
                script {
                    sh 'docker build -t ${DOCKERHUB_REPO} .'
                }
            }
        }

        stage('Subir Imagen a DockerHub') {
            steps {
                // Subir la imagen Docker a DockerHub
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        sh 'docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}'
                        sh 'docker push ${DOCKERHUB_REPO}'
                    }
                }
            }
        }
    }
}
