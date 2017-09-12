#!groovy
node {
    stage('Checkout') {
        checkout scm
    }

    stage('Clean') {
        sh 'make clean'
    }

    stage('Greet') {
        sh 'echo "Hello!"'
    }

    stage('Publish container') {
        sh 'make publish'
    }
}
