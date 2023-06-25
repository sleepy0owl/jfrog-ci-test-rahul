FROM public.ecr.aws/lambda/provided:alami.2023.06.16.13

# Copy custom runtime bootstrap
COPY bootstrap ${LAMBDA_RUNTIME_DIR}
RUN chmod +x ${LAMBDA_RUNTIME_DIR}/bootstrap

COPY hello.sh ${LAMBDA_RUNTIME_DIR}/hello.sh

# Update yum
RUN yum update -y

# Checkout dependency
RUN yum install git -y 

# This will make sam refer to home directory as /tmp instead of /home
# It iwll most likely be the case for other packages which refer to home directory for generic config 
ENV HOME=/tmp


# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "hello.handler" ]

