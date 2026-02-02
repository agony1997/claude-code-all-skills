---
name: devops_cicd
description: "CI/CD 持續整合與部署專家。專精於 GitHub Actions、GitLab CI、Jenkins、自動化測試、部署管道、Docker 整合、版本發布自動化。關鍵字: cicd, ci/cd, github actions, gitlab ci, jenkins, pipeline, 持續整合, 持續部署, 自動化部署"
---

# CI/CD（持續整合/持續部署）專家

你是一位 CI/CD 專家，專精於持續整合、持續交付，以及使用 GitHub Actions、GitLab CI 和 Jenkins 建構自動化管道（Pipeline）。

## 概述

CI/CD 能自動化應用程式的建構、測試與部署流程，實現更快速且更可靠的軟體交付。

## 何時使用此技能

當使用者需要以下操作時，啟用此技能：
- 設定 CI/CD（關鍵字: "cicd", "ci/cd", "pipeline", "持續整合"）
- 使用 GitHub Actions（關鍵字: "github actions", "workflow", "actions"）
- 使用 GitLab CI（關鍵字: "gitlab ci", ".gitlab-ci.yml"）
- 設定 Jenkins（關鍵字: "jenkins", "jenkinsfile"）
- 自動化部署（關鍵字: "deployment", "部署", "自動化部署"）

## 核心概念

### 1. GitHub Actions

**.github/workflows/ci.yml:**
```yaml
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run tests
        run: npm test
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info

  build:
    needs: test
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Push Docker image
        run: |
          docker tag myapp:${{ github.sha }} myregistry/myapp:latest
          docker push myregistry/myapp:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - name: Deploy to production
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.SERVER_HOST }}
          username: ${{ secrets.SERVER_USER }}
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            cd /app
            docker pull myregistry/myapp:latest
            docker-compose up -d
```

**矩陣策略（Matrix Strategy）：**
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
        os: [ubuntu-latest, windows-latest]

    steps:
      - uses: actions/checkout@v3
      - name: Setup Node ${{ matrix.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm test
```

### 2. GitLab CI

**.gitlab-ci.yml:**
```yaml
stages:
  - build
  - test
  - deploy

variables:
  DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

before_script:
  - echo "Starting pipeline..."

# Build stage
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $DOCKER_IMAGE .
    - docker push $DOCKER_IMAGE
  only:
    - main
    - develop

# Test stage
test:
  stage: test
  image: node:18
  services:
    - postgres:15
  variables:
    POSTGRES_DB: test
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
  script:
    - npm ci
    - npm run lint
    - npm test
  coverage: '/Coverage: \d+\.\d+%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
  only:
    - main
    - develop
    - merge_requests

# Deploy to staging
deploy_staging:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache openssh-client
  script:
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | ssh-add -
    - ssh -o StrictHostKeyChecking=no $DEPLOY_USER@$STAGING_SERVER "
        cd /app &&
        docker pull $DOCKER_IMAGE &&
        docker-compose up -d
      "
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

# Deploy to production
deploy_production:
  stage: deploy
  image: alpine:latest
  script:
    - ssh $DEPLOY_USER@$PROD_SERVER "
        cd /app &&
        docker pull $DOCKER_IMAGE &&
        docker-compose up -d
      "
  environment:
    name: production
    url: https://example.com
  when: manual
  only:
    - main
```

### 3. Jenkins Pipeline（Jenkins 管道）

**Jenkinsfile:**
```groovy
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "myapp:${env.BUILD_NUMBER}"
        DOCKER_REGISTRY = "registry.example.com"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                script {
                    sh 'npm ci'
                    sh 'npm run build'
                }
            }
        }

        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                    }
                }
            }
        }

        stage('Code Quality') {
            steps {
                sh 'npm run lint'
                sh 'npm run sonar'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE)
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-credentials') {
                        docker.image(DOCKER_IMAGE).push()
                        docker.image(DOCKER_IMAGE).push('latest')
                    }
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                sh '''
                    ssh user@staging-server "
                        cd /app &&
                        docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE} &&
                        docker-compose up -d
                    "
                '''
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?', ok: 'Deploy'
                sh '''
                    ssh user@prod-server "
                        cd /app &&
                        docker pull ${DOCKER_REGISTRY}/${DOCKER_IMAGE} &&
                        docker-compose up -d
                    "
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline succeeded!'
            slackSend(color: 'good', message: "Build ${env.BUILD_NUMBER} succeeded")
        }
        failure {
            echo 'Pipeline failed!'
            slackSend(color: 'danger', message: "Build ${env.BUILD_NUMBER} failed")
        }
        always {
            junit 'test-results/**/*.xml'
            cleanWs()
        }
    }
}
```

### 4. 常見模式

**語意化版本發佈（Semantic Release）：**
```yaml
# GitHub Actions
- name: Semantic Release
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
  run: npx semantic-release
```

**依賴快取（Dependency Caching）：**
```yaml
# GitHub Actions
- uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

**多環境部署（Multi-environment Deployment）：**
```yaml
deploy:
  script:
    - |
      if [ "$CI_COMMIT_BRANCH" == "main" ]; then
        ENV="production"
      elif [ "$CI_COMMIT_BRANCH" == "develop" ]; then
        ENV="staging"
      else
        ENV="development"
      fi
      kubectl set image deployment/myapp myapp=$DOCKER_IMAGE -n $ENV
```

## 最佳實踐

### 1. 管道階段（Pipeline Stages）
典型的 CI/CD 管道流程：
```
Checkout → Build → Test → Code Quality → Security Scan → Docker Build → Deploy
```

### 2. 快速失敗（Fail Fast）
在執行耗時操作（整合測試、建構）之前，先執行快速測試（lint、單元測試）。

### 3. 使用密鑰管理（Secrets Management）
永遠不要在程式碼中硬編碼憑證：
```yaml
# GitHub Actions
${{ secrets.API_KEY }}

# GitLab CI
$CI_REGISTRY_PASSWORD

# Jenkins
credentials('api-key-id')
```

### 4. 平行執行（Parallel Execution）
```yaml
parallel:
  - unit-tests
  - integration-tests
  - lint
```

### 5. 環境專屬設定（Environment-specific Configuration）
```yaml
deploy_staging:
  environment: staging
  only: [develop]

deploy_production:
  environment: production
  when: manual
  only: [main]
```

### 6. 產出物管理（Artifact Management）
```yaml
artifacts:
  paths:
    - dist/
    - coverage/
  expire_in: 7 days
```

## 快速參考

### GitHub Actions 語法
```yaml
on: [push, pull_request]
jobs:
  job-name:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm test
```

### GitLab CI 語法
```yaml
stages: [build, test, deploy]
job-name:
  stage: test
  script:
    - npm test
  only: [main]
```

### Jenkins Pipeline 語法
```groovy
pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh 'npm test'
      }
    }
  }
}
```

### 常用指令
```bash
# GitHub Actions
gh workflow run ci.yml
gh workflow list
gh run list

# GitLab CI
gitlab-runner exec docker test
gitlab-ci-multi-runner verify

# Jenkins
curl -X POST http://jenkins/job/myjob/build --user user:token
```

---

**請記住：** 良好的 CI/CD 管道應該快速、可靠，並能提供即時回饋。從測試到部署的一切流程都應自動化，以確保一致且無錯誤的發佈。
