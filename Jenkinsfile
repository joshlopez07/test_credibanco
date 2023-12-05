pipeline {
    agent any

    environment {
        // Define las variables de entorno necesarias
        GITHUB_REPO = 'https://github.com/joshlopez07/test_credibanco.git'
        DOCKERHUB_REPO = 'joshlopez07/test-credibanco'
    }

    stages {
        stage('Clonar Repositorio') {
            steps {
                // Clonar el repositorio de GitHub
                script {
                    git branch: 'develop', url: "${GITHUB_REPO}", credentialsId: 'github_credentials'

                }
            }
        }
        stage('Build con Maven') {
            steps {
                // Realizar build con Maven
                script {
                    sh 'mvn clean install'
                }
            }
        }
      
        stage('Ejecutar Pruebas Unitarias') {
            steps {
                // Ejecutar pruebas unitarias con JUnit
                script {
                    sh 'mvn test' // Asegúrate de tener configurado Maven en tu proyecto
                }
            }
        }

        stage('Analizar Código con SonarQube') {
            steps {
                // Analizar código con SonarQube
                script {
                    withSonarQubeEnv('SonarQube_Server') {
                        sh 'mvn sonar:sonar' // Asegúrate de tener configurado SonarQube en tu proyecto
                    }
                }
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
