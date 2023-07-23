@Library('mytools')

import org.mytools.Tools
Tools tools = new Tools(this)

pipeline {
    agent any
    stages {
        stage('test') {
            steps {
                script {
                    tools.myEcho('test')
                }
            }
        }
    }
}