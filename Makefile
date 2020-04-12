#!make
include .env
export $(cat ./.env | xargs)
# order:
	# 1. create-buckets
	# 3. create-roles
	# 4. create-service
	# 5. create-build

create-buckets:
	aws cloudformation create-stack \
  --stack-name ${PROJECT_NAME}-buckets-${ENV} \
  --template-body file://./cloudformation/buckets.json \
  --parameters \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  --profile personal

create-roles:
	aws cloudformation create-stack \
  --stack-name ${PROJECT_NAME}-roles-${ENV} \
  --template-body file://./cloudformation/roles.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=BucketsStack,ParameterValue=${PROJECT_NAME}-buckets-${ENV} \
  --profile personal

create-service:
	aws cloudformation create-stack \
  --stack-name ${PROJECT_NAME}-service-${ENV} \
  --template-body file://./cloudformation/service.json \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=KeyName,ParameterValue=${KEY_NAME} \
  ParameterKey=RolesStack,ParameterValue=${PROJECT_NAME}-roles-${ENV} \
  --profile personal

create-build:
	aws cloudformation create-stack \
  --stack-name ${PROJECT_NAME}-build-${ENV} \
  --template-body file://./cloudformation/build.json \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=BucketsStack,ParameterValue=${PROJECT_NAME}-buckets-${ENV} \
  ParameterKey=RolesStack,ParameterValue=${PROJECT_NAME}-roles-${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=GithubRepoUrl,ParameterValue=${GITHUB_REPO_URL} \
  --profile personal


update-buckets:
	aws cloudformation update-stack \
  --stack-name ${PROJECT_NAME}-buckets-${ENV} \
  --template-body file://./cloudformation/buckets.json \
  --parameters \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  --profile personal



update-roles:
	aws cloudformation update-stack \
  --stack-name ${PROJECT_NAME}-roles-${ENV} \
  --template-body file://./cloudformation/roles.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=BucketsStack,ParameterValue=${PROJECT_NAME}-buckets-${ENV} \
  --profile personal

update-service:
	aws cloudformation update-stack \
  --stack-name ${PROJECT_NAME}-service-${ENV} \
  --template-body file://./cloudformation/service.json \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=KeyName,ParameterValue=${KEY_NAME} \
  ParameterKey=RolesStack,ParameterValue=${PROJECT_NAME}-roles-${ENV} \
  --profile personal

update-build:
	aws cloudformation update-stack \
  --stack-name ${PROJECT_NAME}-build-${ENV} \
  --template-body file://./cloudformation/build.json \
  --parameter \
  ParameterKey=env,ParameterValue=${ENV} \
  ParameterKey=BucketsStack,ParameterValue=${PROJECT_NAME}-buckets-${ENV} \
  ParameterKey=RolesStack,ParameterValue=${PROJECT_NAME}-roles-${ENV} \
  ParameterKey=ServiceStack,ParameterValue=${PROJECT_NAME}-service-${ENV} \
  ParameterKey=ProjectName,ParameterValue=${PROJECT_NAME} \
  ParameterKey=GithubRepoUrl,ParameterValue=${GITHUB_REPO_URL} \
  --profile personal

function-package:
	cd ./build-fn && zip -q ../function.zip ./* && cd ..

function-upload:
	aws s3 cp ./function.zip s3://${PROJECT_NAME}-build-fn-${ENV}/function.zip --profile personal

function-deploy:
	aws lambda update-function-code --function-name body-blog-build-fn-dev --s3-bucket body-blog-build-fn-dev --s3-key function.zip --profile personal
