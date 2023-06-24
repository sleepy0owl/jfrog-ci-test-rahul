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

RUN yum install jq -y

CMD [ "hello.handler" ]