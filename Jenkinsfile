pipeline {

    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    parameters {

        choice(
                name: 'ENVIRONMENT',
                choices: ['dev', 'qa', 'prod'],
                description: 'Select Deployment Environment'
        )

        choice(
                name: 'ACTION',
                choices: ['apply', 'destroy'],
                description: 'Select Terraform Action'
        )

        booleanParam(
                name: 'AUTO_APPROVE',
                defaultValue: false,
                description: 'Skip Manual Approval'
        )
    }

    environment {

        TF_IN_AUTOMATION = "true"
        TF_INPUT = "false"

        TERRAFORM_VERSION = "1.13.2"

        GCP_PROJECT_ID = "gcp-dev-july-2026"

        TF_STATE_BUCKET = "gcp-dev-july-2026-terraform-state"

        GOOGLE_APPLICATION_CREDENTIALS = "${WORKSPACE}/gcp-key.json"

        GOOGLE_CLOUD_PROJECT = "gcp-dev-july-2026"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Check Tools') {
            steps {
                sh '''
            set -e

            echo "===== Installing Terraform ${TERRAFORM_VERSION} ====="
            curl -fsSLo terraform.zip \
              https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
            unzip -o -q terraform.zip
            chmod +x terraform
            rm -f terraform.zip

            echo "===== Terraform ====="
            ./terraform version

            echo "===== gcloud ====="
            which gcloud || true
            gcloud --version || true

            echo "===== Git ====="
            git --version
        '''
            }
        }

        stage('Authenticate to GCP') {
            steps {

                withCredentials([
                        file(credentialsId: 'gcp-sa-key', variable: 'GCP_KEY')
                ]) {

                    sh '''
                cp ${GCP_KEY} ${GOOGLE_APPLICATION_CREDENTIALS}

                gcloud auth activate-service-account \
                    --key-file=${GOOGLE_APPLICATION_CREDENTIALS}

                gcloud config set project ${GCP_PROJECT_ID}

                gcloud auth list

                gcloud config list
            '''
                }
            }
        }

        stage('Terraform Version') {
            steps {
                sh 'terraform version'
            }
        }

        stage('Terraform Init') {
            steps {
                sh """
            ./terraform init \
              -reconfigure \
              -backend-config="bucket=${TF_STATE_BUCKET}" \
              -backend-config="prefix=${params.ENVIRONMENT}"
        """
            }
        }

        stage('Terraform Validate') {
            steps {
                sh './terraform validate'
            }
        }

        stage('Terraform Workspace') {
            steps {

                sh """
                    ./terraform workspace select ${params.ENVIRONMENT} || \
                    ./terraform workspace new ${params.ENVIRONMENT}
                """
            }
        }

        stage('Terraform Plan') {

            steps {

                script {

                    def destroyFlag = (params.ACTION == 'destroy') ? '-destroy' : ''

                    // -detailed-exitcode: 0 = no changes, 1 = error, 2 = changes present
                    def planExitCode = sh(
                            script: """
                            ./terraform plan \
                              -var-file=${params.ENVIRONMENT}.tfvars \
                              -out=tfplan \
                              -detailed-exitcode \
                              ${destroyFlag}
                        """,
                            returnStatus: true
                    )

                    if (planExitCode == 1) {
                        error "Terraform plan failed"
                    } else if (planExitCode == 0) {
                        echo "No changes detected — nothing to ${params.ACTION}. Skipping remaining stages."
                        env.TF_PLAN_EMPTY = 'true'
                    } else {
                        env.TF_PLAN_EMPTY = 'false'
                    }
                }
            }
        }

        stage('Manual Approval') {

            when {
                allOf {
                    expression { !params.AUTO_APPROVE }
                    expression { env.TF_PLAN_EMPTY == 'false' }
                }
            }

            steps {

                timeout(time: 30, unit: 'MINUTES') {

                    input(
                            message: "${params.ACTION == 'destroy' ? 'Destroy' : 'Deploy'} ${params.ENVIRONMENT}?",
                            ok: params.ACTION == 'destroy' ? 'Destroy' : 'Deploy'
                    )
                }
            }
        }

        stage('Terraform Apply') {

            when {
                expression { env.TF_PLAN_EMPTY == 'false' }
            }

            steps {

                sh '''
                    ./terraform apply -auto-approve tfplan
                '''
            }
        }

    }

    post {

        always {

            archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true

            cleanWs()
        }

        success {

            echo "${params.ACTION == 'destroy' ? 'Destroy' : 'Deployment'} Successful"
        }

        failure {

            echo "${params.ACTION == 'destroy' ? 'Destroy' : 'Deployment'} Failed"
        }
    }
}