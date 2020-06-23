pipeline {
    agent none
    triggers {
        cron(env.BRANCH_NAME == 'master' ? '@weekly' : '')
    }
    environment {
        KONG_SOURCE = "master"
        KONG_SOURCE_LOCATION = "/tmp/kong"
        DOCKER_USERNAME = "${env.DOCKERHUB_USR}"
        DOCKER_PASSWORD = "${env.DOCKERHUB_PSW}"
        DOCKERHUB = credentials('dockerhub')
    }
    stages {
        stage('Test Builds') {
            parallel {
                stage('Other Builds'){
                    agent {
                        node {
                            label 'bionic'
                        }
                    }
                    steps {
                        sh 'git clone --single-branch --branch ${KONG_SOURCE} https://github.com/Kong/kong.git ${KONG_SOURCE_LOCATION}'
                        sh 'export RESTY_IMAGE_BASE=alpine RESTY_IMAGE_TAG=3 PACKAGE_TYPE=apk && make package-kong && make test && make cleanup'
                    }
                }
                stage('Centos Builds'){
                    agent {
                        node {
                            label 'bionic'
                        }
                    }
                    environment {
                        DEBUG = 0
                        PACKAGE_TYPE = "rpm"
                        RESTY_IMAGE_BASE = "centos"
                        PATH = "/home/ubuntu/bin/:${env.PATH}"
                    }
                    steps {
                        sh 'mkdir -p /home/ubuntu/bin/'
                        sh 'git clone --single-branch --branch ${KONG_SOURCE} https://github.com/Kong/kong.git ${KONG_SOURCE_LOCATION}'
                        sh 'export RESTY_IMAGE_TAG=8 && make package-kong || true'
                        sh 'export RESTY_IMAGE_TAG=7 && make package-kong || true'
                        sh 'export RESTY_IMAGE_TAG=6 && make package-kong || true'
                    }
                }
                stage('Debian Builds'){
                    agent {
                        node {
                            label 'bionic'
                        }
                    }
                    environment {
                        DEBUG = 0
                        PACKAGE_TYPE = "deb"
                        RESTY_IMAGE_BASE = "debian"
                        PATH = "/home/ubuntu/bin/:${env.PATH}"
                    }
                    steps {
                        sh 'mkdir -p /home/ubuntu/bin/'
                        sh 'git clone --single-branch --branch ${KONG_SOURCE} https://github.com/Kong/kong.git ${KONG_SOURCE_LOCATION}'
                        sh 'export RESTY_IMAGE_TAG=stretch && make package-kong || true'
                        sh 'export RESTY_IMAGE_TAG=jessie && make package-kong || true'
                        sh 'export RESTY_IMAGE_TAG=buster && make package-kong || true'
                        sh 'export RESTY_IMAGE_TAG=bullseye && make package-kong || true'
                    }
                }
                stage('Ubuntu Builds'){
                    agent {
                        node {
                            label 'bionic'
                        }
                    }
                    options {
                        retry(2)
                    }
                    environment {
                        DEBUG = 0
                        PACKAGE_TYPE = "deb"
                        RESTY_IMAGE_BASE = "ubuntu"
                        PATH = "/home/ubuntu/bin/:${env.PATH}"
                        USER = 'travis'
                    }
                    steps {
                        sh 'mkdir -p /home/ubuntu/bin/'
                        sh 'git clone --single-branch --branch ${KONG_SOURCE} https://github.com/Kong/kong.git ${KONG_SOURCE_LOCATION}'
                        sh 'export BUILDX=false RESTY_IMAGE_TAG=bionic && make package-kong && make test && make cleanup'
                        sh 'export BUILDX=false UPDATE_CACHE=true RESTY_IMAGE_TAG=xenial DOCKER_MACHINE_ARM64_NAME="jenkins-kong-"`cat /proc/sys/kernel/random/uuid` && make package-kong && make test'
                        sh 'export BUILDX=false RESTY_IMAGE_TAG=focal && make package-kong && make test && make cleanup'
                    }
                    post {
                        always {
                            sh 'make cleanup-build'
                        }
                    }
                }
            }
        }
    }
}
