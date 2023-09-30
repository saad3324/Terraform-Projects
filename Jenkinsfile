#!/usr/bin/env groovy

library identifier: 'jenkins-shared-library@AWS-Practice', retriever: modernSCM(
    [
        $class: 'GitSCMSource',
        remote: 'https://gitlab.com/saad324/jenkins-shared-library.git',
        credentialsId: 'saad-git'
    ]
)

pipeline {
    agent any
    tools {
        maven 'Maven'
    }
   

    stages {
        stage('increment version') {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                }
            }
        }

        stage("build app") {
            steps {
                script {
                    buildApp()
                }
            }
        }

       stage("build and push image") {
            steps {
                 script {
                 imageName = "saad324/saad-docker:${IMAGE_NAME}"
                 buildImage(imageName)
                 dockerLogin()
                 dockerPush(imageName)
        }
    }
}


        stage("test") {
            steps {
                script {
                    echo "testing the app"
                }
            }
        }
        stage("provision server") {

            environment {
                AWS_ACCESS_KEY_ID = credentials('Access-key-ID')
                AWS_SECRET_ACCESS_KEY = credentials('Secret-access-key')
                TF_VAR_env_prefix = 'test'
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }

        stage('deploy') {
            environment {
                DOCKER_CREDS = credentials('saad-docker-repo')
            }



            steps {
                script {

                    echo "wating for server init"
                    sleep(time: 90, unit: "SECONDS")
                    echo "${EC2_PUBLIC_IP}"


                    echo "Deploying the application..."
                     def shellCmd = "bash ./server-cmds.sh ${imageName} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                   def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

                   sshagent(['SSH_key_aws']) {
                       sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                       sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"

                    }
                }
            }
        }

        stage('commit update') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'saad-git', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh 'git config --global user.email "saadi57214@gmail.com"'
                        sh 'git config --global user.name "saad324"'

                        sh 'git status'
                        sh 'git branch'
                        sh 'git config --list'

                        sh "git remote set-url origin https://${USERNAME}:${PASSWORD}@gitlab.com/saad324/terraforms-project.git"

                        sh 'git add .'
                        sh 'git commit -m "version update"'
                        sh 'git push origin HEAD:terraform-CI/CD'
                    }
                }
            }
        }
    }
}
