FROM public.ecr.aws/lambda/python:3.9

# Copy custom runtime bootstrap
# Copy requirements.txt
COPY requirements.txt ${LAMBDA_TASK_ROOT}

RUN pip install -r requirements.txt

# Copy function code
COPY handler.py ${LAMBDA_TASK_ROOT}

RUN yum install git -y

RUN git config --system http.sslVerify false
RUN git config --system user.email "sourav.mondal@antstack.io"

ENV HOME=/tmp

CMD [ "handler.handler" ]