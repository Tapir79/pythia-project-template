#!groovy
node {
    stage('Checkout') {
        checkout scm
    }

    stage('Clean') {
        sh 'rm version.json'
    }

    stage('Greet') {
        sh 'echo "Hello!"'
    }

    stage('Publish container') {
        sh 'make publish'
    }
}
