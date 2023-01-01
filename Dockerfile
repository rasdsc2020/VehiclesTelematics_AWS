FROM python:3.8-slim-buster

RUN apt-get update && apt-get install -y wget && apt-get install -y unzip
# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/0.15.0/terraform_0.15.0_linux_amd64.zip && \
    unzip terraform_0.15.0_linux_amd64.zip && \
    mv terraform /usr/local/bin/

# Install the necessary dependencies
RUN apt-get update && \
    apt-get install -y build-essential python3-dev

# Install pandas
RUN pip install pandas

# Add the Terraform configuration files and scripts
ADD . /app
WORKDIR /app

# Install faker and boto3 
RUN pip install -r requirements.txt

# Run Terraform to build the AWS architecture
RUN terraform init && \
    terraform destroy -auto-approve

RUN terraform apply -auto-approve

CMD ["main.py"]
ENTRYPOINT ["python"]