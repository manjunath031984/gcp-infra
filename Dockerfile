FROM jenkins/jenkins:lts-jdk21

USER root

ENV DEBIAN_FRONTEND=noninteractive
ARG TERRAFORM_VERSION=1.13.2

# Install required packages
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        unzip \
        git \
        jq \
        gnupg \
        apt-transport-https \
        ca-certificates \
        lsb-release && \
    rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------
# Install Terraform
# -------------------------------------------------------
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# -------------------------------------------------------
# Install Google Cloud CLI
# -------------------------------------------------------
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    > /etc/apt/sources.list.d/google-cloud-sdk.list

RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

RUN apt-get update && \
    apt-get install -y google-cloud-cli && \
    rm -rf /var/lib/apt/lists/*

# -------------------------------------------------------
# Verify installations
# -------------------------------------------------------
RUN terraform version
RUN gcloud --version
RUN git --version

USER jenkins

ENV PATH="/usr/local/bin:${PATH}"

WORKDIR /var/jenkins_home

EXPOSE 8090 50001

CMD ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]