FROM public.ecr.aws/lambda/provided:alami.2023.06.16.13

# Copy custom runtime bootstrap
COPY bootstrap ${LAMBDA_RUNTIME_DIR}
RUN chmod +x ${LAMBDA_RUNTIME_DIR}/bootstrap


# Copy function code
# COPY hello.sh ${LAMBDA_TASK_ROOT}
# RUN chmod +x ${LAMBDA_TASK_ROOT}/hello.sh

COPY hello.sh ${LAMBDA_RUNTIME_DIR}/hello.sh

# Update yum
RUN yum update -y

# Checkout dependency
RUN yum install git -y 


# Install node - required for sam cli 
RUN yum install -y gcc-c++ make

# Install Node.js
RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash - \
    && yum install -y nodejs

# Update npm
RUN npm install -g npm

# Backend dependency - for SAM / AWS
RUN yum install -y unzip
RUN curl -sSL "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o "sam.zip" \
    && unzip sam.zip -d sam-installation \
    && ./sam-installation/install
RUN yum clean all && rm -rf /var/cache/yum && rm -rf sam.zip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install
RUN yum clean all && rm -rf /var/cache/yum && rm -rf awscliv2.zip



#Frontend dependency
RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo --output /etc/yum.repos.d/yarn.repo
RUN yum install yarn -y


#Miscellaneous
RUN yum install jq -y


# This will make sam refer to home directory as /tmp instead of /home
# It iwll most likely be the case for other packages which refer to home directory for generic config 
ENV HOME=/tmp


# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "hello.handler" ]

