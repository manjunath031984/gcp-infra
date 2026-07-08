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

        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Skip Manual Approval'
        )
    }

    environment {

    TF_IN_AUTOMATION = "true"
    TF_INPUT = "false"

    GCP_PROJECT_ID = "gcp-dev-july-2026"

    TF_STATE_BUCKET = "terraform-state-gcp-bucket"

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
            echo "Checking Terraform..."
            which terraform
            terraform version

            echo "Checking gcloud..."
            which gcloud || true
            gcloud --version || true
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
            terraform init \
              -reconfigure \
              -backend-config="bucket=${TF_STATE_BUCKET}" \
              -backend-config="prefix=${params.ENVIRONMENT}"
        """
    }
}

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Workspace') {
            steps {

                sh """
                    terraform workspace select ${params.ENVIRONMENT} || \
                    terraform workspace new ${params.ENVIRONMENT}
                """
            }
        }

        stage('Terraform Plan') {

            steps {

                sh """
                    terraform plan \
                      -var-file=${params.ENVIRONMENT}.tfvars \
                      -out=tfplan
                """
            }
        }

        stage('Manual Approval') {

            when {
                expression {
                    !params.AUTO_APPROVE
                }
            }

            steps {

                timeout(time: 30, unit: 'MINUTES') {

                    input(
                        message: "Deploy to ${params.ENVIRONMENT}?",
                        ok: "Deploy"
                    )
                }
            }
        }

        stage('Terraform Apply') {

            steps {

                sh '''
                    terraform apply -auto-approve tfplan
                '''
            }
        }

    }

    post {

        always {

            archiveArtifacts artifacts: 'tfplan'

            cleanWs()
        }

        success {

            echo "Deployment Successful"
        }

        failure {

            echo "Deployment Failed"
        }
    }
}