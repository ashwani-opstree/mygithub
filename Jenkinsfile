@Library('mytools') _
import org.mytools.Utils
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