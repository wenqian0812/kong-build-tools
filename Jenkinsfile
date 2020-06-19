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
        stage('Build Kong') {
            when {
                beforeAgent true
                anyOf {
                    buildingTag()
                    branch 'master'
                    changeRequest target: 'master'
                }
            }
            agent {
                node {
                    label 'bionic'
                }
            }
            steps {
                sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin || true'
                sh 'git clone --single-branch --branch $KONG_SOURCE https://github.com/Kong/kong.git $KONG_SOURCE_LOCATION'
                sh 'make kong-test-container'
            }
        }
        stage('Tests Kong') {
            when {
                beforeAgent true
                anyOf {
                    buildingTag()
                    branch 'master'
                    changeRequest target: 'master'
                }
            }
            parallel {
                stage('dbless') {
                    agent {
                        node {
                            label 'bionic'
                        }
                    }
                    environment {
                        TEST_DATABASE = "off"
                        TEST_SUITE = "dbless"
                    }
                    steps {
                        sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin || true'
                        sh 'git clone --single-branch --branch $KONG_SOURCE https://github.com/Kong/kong.git $KONG_SOURCE_LOCATION'
                        sh 'make test-kong'
                    }
                }
                stage('postgres') {
                    agent {
                        node {
                            label 'bionic'
                        }
                    }
                    environment {
                        TEST_DATABASE = 'postgres'
                    }
                    steps {
                        sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin || true'
                        sh 'git clone --single-branch --branch $KONG_SOURCE https://github.com/Kong/kong.git $KONG_SOURCE_LOCATION'
                        sh 'make test-kong'
                    }
                }
                stage('postgres plugins') {
                    agent {
                        node {
                            label 'bionic'
                        }
                    }
                    environment {
                        TEST_DATABASE = 'postgres'
                        TEST_SUITE = 'plugins'
                    }
                    steps {
                        sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin || true'
                        sh 'git clone --single-branch --branch $KONG_SOURCE https://github.com/Kong/kong.git $KONG_SOURCE_LOCATION'
                        sh 'make test-kong'
                    }
                }
                stage('cassandra') {
                    agent {
                        node {
                            label 'bionic'
                        }
                    }
                    environment {
                        TEST_DATABASE = 'cassandra'
                    }
                    steps {
                        sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin || true'
                        sh 'git clone --single-branch --branch $KONG_SOURCE https://github.com/Kong/kong.git $KONG_SOURCE_LOCATION'
                        sh 'make test-kong'
                    }
                }
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
                AWS_ACCESS_KEY = credentials('AWS_ACCESS_KEY')
                AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
            }
            steps {
                sh 'mkdir -p /home/ubuntu/bin/'
                sh 'git clone --single-branch --branch ${KONG_SOURCE} https://github.com/Kong/kong.git ${KONG_SOURCE_LOCATION}'
                sh 'export BUILDX=false RESTY_IMAGE_TAG=bionic && make package-kong && make test && make cleanup'
                sh 'export CACHE=false UPDATE_CACHE=true RESTY_IMAGE_TAG=xenial DOCKER_MACHINE_ARM64_NAME="jenkins-kong-"`cat /proc/sys/kernel/random/uuid` && make package-kong && make test'
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
