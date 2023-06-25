FROM public.ecr.aws/lambda/nodejs:16

# Copy function code
COPY index.js ${LAMBDA_TASK_ROOT}

# Install node - required for sam cli 
RUN yum install -y gcc-c++ make

# Install Node.js
RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash - \
    && yum install -y nodejs

# Update npm
RUN npm install -g npm


RUN yum install -y unzip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install
RUN yum clean all && rm -rf /var/cache/yum && rm -rf awscliv2.zip


#Miscellaneous
RUN yum install jq -y



# This will make sam refer to home directory as /tmp instead of /home
# It iwll most likely be the case for other packages which refer to home directory for generic config 
ENV HOME=/tmp


# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "index.handler" ]