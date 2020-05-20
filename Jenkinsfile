pipeline {
    agent none
    environment {
        KONG_SOURCE = "2.1.0-alpha.1"
        KONG_SOURCE_LOCATION = "/tmp/kong"
    }
    stages {
        stage('Build Kong') {
            agent {
                node {
                    label 'docker-compose'
                }
            }
            steps {
                sh 'bash --version'
                sh 'awk --version'
                sh 'sed --version'
                sh 'git clone --single-branch --branch $KONG_SOURCE https://github.com/Kong/kong.git $KONG_SOURCE_LOCATION'
                sh 'make debug'
            }
        }
    }
}
