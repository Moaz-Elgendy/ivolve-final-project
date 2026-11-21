// One Jenkins host serves all environments: run this job and pick ENV (dev | stg | prod).
// ENV selects the git branch to build, the ECR repos (<service>-<ENV>) and the values file to update.
//
// One-time Jenkins setup:
//  * Manage Jenkins > System > Global Trusted Pipeline Libraries: name ivolve-shared-library,
//    this repo (https), default version main, library path jenkins/shared-library
//  * Credential 'github-https' (username + GitHub personal access token with repo write),
//    used only to push the imageTag commit. The repo is public, so checkout needs no credential.
@Library('ivolve-shared-library') _

def services = [
    [name: 'frontend',        context: 'app/frontend'],
    [name: 'auth-service',    context: 'app/auth-service'],
    [name: 'roadmap-service', context: 'app/roadmap-service'],
]

pipeline {
    agent any

    parameters {
        choice(name: 'ENV', choices: ['dev', 'stg', 'prod'], description: 'Branch / environment to build and update')
    }

    environment {
        // Registry host is derived from the instance IAM role, so the account ID is not stored in git
        REGISTRY   = "${sh(returnStdout: true, script: 'aws sts get-caller-identity --query Account --output text').trim()}.dkr.ecr.eu-west-1.amazonaws.com"
        REPO_URL   = 'https://github.com/Moaz-Elgendy/ivolve-final-project.git'
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: params.ENV, url: env.REPO_URL
            }
        }

        stage('Build') {
            steps {
                script {
                    services.each { s -> buildImage(registry: env.REGISTRY, repo: "${s.name}-${params.ENV}", context: s.context, tag: env.IMAGE_TAG) }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    services.each { s -> testImage(registry: env.REGISTRY, repo: "${s.name}-${params.ENV}", tag: env.IMAGE_TAG) }
                }
            }
        }

        stage('Push') {
            steps {
                script {
                    services.each { s -> pushImage(registry: env.REGISTRY, repo: "${s.name}-${params.ENV}", tag: env.IMAGE_TAG) }
                }
            }
        }

        // Argo CD watches this branch and syncs the change; Jenkins never touches the cluster
        stage('Update deploy branch') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-https', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                    // single-quoted: the shell expands the variables, so the token never enters Groovy
                    sh '''
                        f=helm/ivolve/values-${ENV}.yaml
                        sed -i "s/^imageTag:.*/imageTag: \\"${IMAGE_TAG}\\"/" $f
                        git config user.name  "jenkins"
                        git config user.email "jenkins@ivolve.local"
                        git add $f
                        git diff --cached --quiet || git commit -m "ci(${ENV}): deploy build ${IMAGE_TAG}"
                        git push "https://${GIT_USER}:${GIT_TOKEN}@${REPO_URL#https://}" HEAD:${ENV}
                    '''
                }
            }
        }
    }
}
