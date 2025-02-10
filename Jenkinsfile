#!/usr/bin/env groovy
import groovy.json.*

iccrBaseUrl = env.ICCR_BASE_URL

pipeline {
  agent none
  stages {
    stage('Initial steps') {
      options {
        skipDefaultCheckout true
      }
      agent {
        label 'ubi9-x86-agent'
      }
      steps{
        script{
          buildlabel = sh(returnStdout: true, script: 'date +\'%Y%m%d-%H%M\'').trim()
          iccrRepository = 'podman-in-podman'
          iccrNamespace = getICCRNamespace()
          sh "echo Using the Buildlabel: ${buildlabel}"
        }
      }
    }
    stage('Build and Push') {
      parallel {
        stage('x86') {
          agent {
            label 'ubi9-x86-agent'
          }
          steps {
            script {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'IBM_CLOUD_IAM_API_KEY_FOR_ICR_ACCESS', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh "podman login -u ${USERNAME} -p ${PASSWORD} https://${iccrBaseUrl}"  
                    sh "podman build --no-cache -t ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${buildlabel}-x86 -f Dockerfile"
                    sh "podman push ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${buildlabel}-x86"
                    sh "podman rmi ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${buildlabel}-x86"
                }
            }
          }
        }
        stage('ppc64le') {
          agent {
            label 'ubi8-ppc64le-agent'
          }
          steps {
            script {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'IBM_CLOUD_IAM_API_KEY_FOR_ICR_ACCESS', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh "podman login -u ${USERNAME} -p ${PASSWORD} https://${iccrBaseUrl}"       
                    sh "podman build --no-cache -t ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${buildlabel}-ppc64le -f Dockerfile"
                    sh "podman push ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${buildlabel}-ppc64le"
                    sh "podman rmi ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${buildlabel}-ppc64le"
                }
            }
          }
        }
        stage('s390x') {
          agent {
            label 'ubi9-s390x-agent'
          }
          steps {
            script {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'IBM_CLOUD_IAM_API_KEY_FOR_ICR_ACCESS', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh "podman login -u ${USERNAME} -p ${PASSWORD} https://${iccrBaseUrl}"     
                    sh "podman build --no-cache -t ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${buildlabel}-s390x -f Dockerfile"
                    sh "podman push ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${buildlabel}-s390x"
                    sh "podman rmi ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${buildlabel}-s390x"
                }
            }
          }
        }
      }
    }

    stage('Promotion of Nested Podman Builder'){
      options {
        skipDefaultCheckout true
      }
      agent {
        label 'ubi9-x86-agent'
      }
      steps{
        script{
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'IBM_CLOUD_IAM_API_KEY_FOR_ICR_ACCESS', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                sh "podman login https://${iccrBaseUrl} -u ${USERNAME} -p ${PASSWORD}"

                sh "echo Using the Buildlabel: ${buildlabel}"
                sh "echo Using the repository: ${iccrNamespace}/${iccrRepository}"

                createMultiArchImage ("${iccrNamespace}/${iccrRepository}", "${buildlabel}")
                if (env.BRANCH_NAME == 'main') {
                    retagLatestImage("${buildlabel}-x86", "latest-x86")
                    retagLatestImage("${buildlabel}-ppc64le", "latest-ppc64le")
                    retagLatestImage("${buildlabel}-s390x", "latest-s390x")
                    createMultiArchImage ("${iccrNamespace}/${iccrRepository}", "latest")
                }
            }
        }
      }
    }  
  }
}

def retagLatestImage (dockerSourceTag, dockerTargetTag) {
    sh "podman pull ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${dockerSourceTag}"
    sh "podman tag ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${dockerSourceTag} ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${dockerTargetTag}"
    sh "podman push ${iccrBaseUrl}/${iccrNamespace}/${iccrRepository}:${dockerTargetTag}"
}

def createMultiArchImage (iccrRepository, imageLabel) {
    sh "podman manifest create ${iccrBaseUrl}/${iccrRepository}:${imageLabel}"
    sh "podman manifest add ${iccrBaseUrl}/${iccrRepository}:${imageLabel} ${iccrBaseUrl}/${iccrRepository}:${imageLabel}-x86 --arch amd64"
    sh "podman manifest add ${iccrBaseUrl}/${iccrRepository}:${imageLabel} ${iccrBaseUrl}/${iccrRepository}:${imageLabel}-ppc64le --arch ppc64le"
    sh "podman manifest add ${iccrBaseUrl}/${iccrRepository}:${imageLabel} ${iccrBaseUrl}/${iccrRepository}:${imageLabel}-s390x --arch s390x"
    sh "podman manifest push ${iccrBaseUrl}/${iccrRepository}:${imageLabel}"
}

boolean isProtectedBranch() {
  return env.BRANCH_NAME  == "main"
}

def getICCRNamespace() {
  return isProtectedBranch() ? "idaa-prod" : "idaa-dev"
}
