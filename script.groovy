#!/usr/bin/env bash

def testApp() {
    echo "Testing the app"
}

def deployApp() {
    echo "Deploying the application..."
    def shellCMD = "bash ./server-cmds.sh ${IMAGE_NAME}"



        def ec2Login = 'ec2-user@18.133.197.170'
    sshagent(['ec2-Docker-ssh-key']) {
        sh "scp server-cmds.sh ${ec2Login}:/home/ec2-user"
        sh "scp docker-compose.yaml ${ec2Login}:/home/ec2-user"
        sh "ssh -o StrictHostKeyChecking=no ${ec2Login} ${shellCMD}"
    }


}



return this

