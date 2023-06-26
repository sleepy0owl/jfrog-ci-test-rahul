FROM public.ecr.aws/amazonlinux/amazonlinux:latest

USER root

# Install dependencies 
RUN yum update -y
RUN yum install -y docker 
RUN yum install -y tar 
RUN yum install -y golang 
RUN yum install -y git 
RUN yum install -y amazon-cloudwatch-agent

# Install amazon cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o  "awscliv2.zip" && \
    unzip awscliv2.zip &&\
    ./aws/install
RUN aws --version

RUN mkdir -p /app
COPY function.sh /app/function.sh
RUN chmod +x /app/function.sh

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "/app/function.sh" ]