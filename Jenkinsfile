pipeline {
    agent any

    environment {
        // Definir variables de entorno
        GITHUB_REPO = 'https://github.com/joshlopez07/test_credibanco.git'
        DOCKERHUB_REPO = 'joshlopez07/test-credibanco'
        SONAR_TOKEN = '44e6312071241f6f998e64469a745e5ff14fae45'
        AWS_REGION = 'us-east-1'
        ELASTIC_BEANSTALK_ENV_NAME = 'Novatec-env'
        DOCKER_IMAGE_NAME = '${DOCKERHUB_REPO}:latest'
        S3_BUCKET = 'elasticbeanstalk-us-east-1-898852446082'
        JMETER_SCRIPT = '/root/jenkins/apache-jmeter-5.4.1/script.jmx'
        JMETER_HOME = '/root/jenkins/apache-jmeter-5.4.1/apache-jmeter'
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
                script {
                    sh 'mvn clean install'
                }
                sh "ls -la"
            }
        }
      
        stage('Ejecutar Pruebas Unitarias') {
            steps {
                // Ejecutar pruebas unitarias con JUnit
                script {
                    sh 'mvn test' // Asegúrate de tener configurado Maven en tu proyecto
                }
                sh "ls -la"
            }
        }

        stage('Analizar Código con SonarQube') {
            steps {
                // Analizar código con SonarQube
                script {
                    withSonarQubeEnv('SonarCloud') {
                        // Asegúrate de tener configurado SonarQube en tu proyecto
                        sh 'mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=joshlopez07_test_credibanco'
                    }
                }
                sh "ls -la"
            }
        }

        stage('OWASP Dependency-Check Vulnerabilities') {
            steps {
                dependencyCheck additionalArguments: ''' 
                    -o './'
                    -s './'
                    -f 'ALL' 
                    --prettyPrint''', odcInstallation: 'OWASP Dependency-Check Vulnerabilities'
        
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
        }
        
        stage('Construir y Subir Imagen a DockerHub') {
            steps {
                // Subir la imagen Docker a DockerHub
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKERHUB_PASSWORD', usernameVariable: 'DOCKERHUB_USERNAME')]) {
                        sh 'docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}'
                        sh 'docker build -t ${DOCKERHUB_REPO} .'
                        sh 'docker push ${DOCKERHUB_REPO}'
                    }
                }
            }
        }
        stage('Desplegar en Elastic Beanstalk') {
            steps {
                script {
                    // Despliega la imagen Docker en Elastic Beanstalk
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "AWS-Credentials", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]){
                        sh script: "aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID | aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY | aws configure set default.region ${AWS_REGION}", label: "Autenticando a Jenkins en AWS"
                        // Empaqueta la imagen Docker y súbelo a Amazon S3
                        sh """
                            docker save -o image.zip ${DOCKER_IMAGE_NAME}
                            aws s3 cp image.zip s3://${S3_BUCKET}/test-credibanco-${BUILD_NUMBER}.zip
                        """
                        sh """
                            aws elasticbeanstalk create-application-version \
                                --application-name novatec \
                                --version-label v-${BUILD_NUMBER} \
                                --source-bundle S3Bucket=${S3_BUCKET},S3Key=test-credibanco-${BUILD_NUMBER}.zip

                            aws elasticbeanstalk update-environment \
                                --application-name novatec \
                                --environment-name $ELASTIC_BEANSTALK_ENV_NAME \
                                --version-label v-${BUILD_NUMBER}
                            """
                    }
                }
            }
        }
        stage('Ejecutar JMeter en Elastic Beanstalk') {
            steps {
                script {

                    /*/ Descarga JMeter en tu entorno de Jenkins
                    sh """
                        wget -O apache-jmeter.tgz https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.4.1.tgz
                        tar -xzf apache-jmeter.tgz
                    """

                    // Copia tu script JMeter al entorno de Jenkins
                    sh "cp ${JMETER_SCRIPT} ${JMETER_HOME}/bin" */

                    // Ejecuta JMeter en Elastic Beanstalk
                    sh """
                        aws configure set default.region ${AWS_REGION}
                        aws elasticbeanstalk create-environment \
                            --application-name novatec \
                            --environment-name ${ELASTIC_BEANSTALK_ENV_NAME} \
                            --solution-stack-name "64bit Amazon Linux 2 v4.2.2 running Multi-container Docker 21.10.0 (Generic)"

                        aws elasticbeanstalk update-environment \
                            --application-name novatec \
                            --environment-name ${ELASTIC_BEANSTALK_ENV_NAME} \
                            --option-settings Namespace=aws:elasticbeanstalk:application:environment,OptionName=JMETER_HOME,Value=${JMETER_HOME}

                        aws elasticbeanstalk restart-app-server \
                            --environment-name ${ELASTIC_BEANSTALK_ENV_NAME}
                    """

                    // Ejecuta JMeter en Elastic Beanstalk
                    sh "${JMETER_HOME}/bin/jmeter -n -t ${JMETER_SCRIPT}"
                }
            }
        }
    }
}
