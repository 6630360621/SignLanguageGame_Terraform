# Cloud Sign Language Game

This project is a sign-language learning game with a React frontend, a FastAPI backend, and AWS infrastructure managed with Terraform/OpenTofu.

## What it includes

- Frontend: React + TypeScript + Vite
- Backend: FastAPI + Uvicorn
- Authentication: AWS Cognito
- Hosting: AWS Amplify for the frontend
- Deployment: AWS ECS, RDS, API Gateway, Cognito, and related networking resources through Terraform

## Project layout

```text
Cloud-Sign-language/
    backend/        FastAPI application
    frontend/       React application
    Terraform/      Infrastructure as code
```

## Requirements

- Node.js 18 or newer
- Python 3.10 or newer
- AWS account with permissions for ECS, RDS, Cognito, Amplify, IAM, VPC, and API Gateway
- Terraform 1.6+ or OpenTofu 1.6+
- GitHub repository for Amplify hosting
- A GitHub access token is mandatory if you want Terraform to build and deploy Amplify for you

## Local development

### 1. Backend

Create `backend/.env` from `backend/.env.example` and fill in the Cognito values.

```env
COGNITO_REGION=us-east-1
USER_POOL_ID=<your-user-pool-id>
APP_CLIENT_ID=<your-app-client-id>
```

Run the backend:

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Backend URL:

- API: `http://localhost:8000`
- Docs: `http://localhost:8000/docs`

### 2. Frontend

Create `frontend/.env` from `frontend/.env.example` and set your Cognito values.

Run the frontend:

```bash
cd frontend
npm install
npm run dev
```

Frontend URL:

- `http://localhost:5173`

## Deploy to AWS

The Terraform configuration is in `Terraform/`. Update `terraform.tfvars` from `terraform.tfvars.example` before applying.

### 0. Generate a GitHub PAT and store it in Secrets Manager

Terraform can use a GitHub fine-grained personal access token to manage Amplify. Create the token first, then store it in AWS Secrets Manager in the same region you plan to use for Terraform.

#### Generate a fine-grained personal access token

1. Go to GitHub, open your profile picture, and select Settings.
2. In the left sidebar, open Developer settings.
3. Select Personal access tokens, then Fine-grained tokens, and choose Generate new token.
4. Grant access to the repository that contains this project.
5. Give the token these permissions:
    - Contents: Read-only
    - Webhooks: Read & Write
6. Generate the token and copy the value immediately.

#### Store the token in AWS Secrets Manager

7. Open the AWS Console, go to Secrets Manager, and choose Store a new secret.
8. Select Other type of secret.
9. Switch to the Plaintext tab, remove the default key-value pair, and paste only the raw token value.
10. Choose Next, give the secret a name such as `SignBridge/amplify/github-token`, and continue.
11. Finish the wizard and copy the secret name, because you will need it in `terraform.tfvars`.

### 1. Prepare `terraform.tfvars`

Set these required values:

```hcl
aws_region = "us-east-1"
db_password = "ChangeMe123!"
image_uri   = "<your-ecr-image-uri>"

amplify_project_name = "Cloud-Sign-Language"
amplify_app_name     = "Cloud-Sign-Language-frontend"
amplify_repository   = "https://github.com/<your-org>/<your-repo>"
amplify_branch_name  = "main"
amplify_app_root     = "frontend"

cognito_domain_prefix = "cloud-sign-language-auth-unique-prefix"
cognito_callback_urls = ["http://localhost:5173"]
cognito_logout_urls   = ["http://localhost:5173"]

api_cors_allowed_origins = ["http://localhost:5173"]
```

If you want Terraform to manage the Amplify build, store the GitHub access token in AWS Secrets Manager and set `amplify_access_token_secret_name`.

### 2. Build and push the backend image to Amazon ECR

The backend must be containerized and pushed to Amazon ECR in the same region you plan to deploy the app before running Terraform.

#### Create an ECR repository

```bash
aws ecr create-repository --repository-name <your-backend-repository-name> --region <your-region>
```

#### Create an IAM role or user with ECR push permissions

Create a policy with the following JSON and attach it to an IAM user or role:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECRAuth",
            "Effect": "Allow",
            "Action": "ecr:GetAuthorizationToken",
            "Resource": "*"
        },
        {
            "Sid": "ECRPushOneRepo",
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart"
            ],
            "Resource": "arn:aws:ecr:<your-region>:<account-id>:repository/<your-backend-repository-name>"
        }
    ]
}
```

#### Authenticate, build, and push

Log in to AWS CLI using the user or role created above, then run:

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region <your-region> \
    | docker login --username AWS \
        --password-stdin <account-id>.dkr.ecr.<your-region>.amazonaws.com

# Build and push
cd backend
docker build -t <your-backend-repository-name> .
docker tag <your-backend-repository-name>:latest \
    <account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-backend-repository-name>:latest
docker push <account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-backend-repository-name>:latest
```

Note the full image URI, because you will need it as `image_uri` in `terraform.tfvars`.

### 3. Apply infrastructure

From the `Terraform/` directory:

```bash
tofu init
tofu plan
tofu apply
```

If you use Terraform instead of OpenTofu, the commands are the same except for the binary name.

## How to use the app

1. Open the deployed frontend URL.
2. Sign up or sign in through Cognito.
3. Allow camera access when prompted.
4. Start a game session and follow the sign-language prompts.
5. View your score on the leaderboard.

## API endpoints

- `GET /user/me` - current user profile
- `POST /user/login-log` - record login
- `POST /user/logout-log` - record logout
- `GET /user/session-check` - session heartbeat
- `GET /leaderboard/leaderboard` - leaderboard data
- `POST /leaderboard/score` - submit score
- `POST /game/start` - start a game session
- `POST /game/detect` - detect sign input



