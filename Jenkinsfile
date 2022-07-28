def PROJECT_NAME = "edu13-backend"
def GIT_OPS_NAME = "edu13-gitops"
def GIT_ACCOUNT = "shclub"
def gitOpsUrl = "github.com/${GIT_ACCOUNT}/${GIT_OPS_NAME}"
def gitHubOrigin = "github.com/${GIT_ACCOUNT}/${PROJECT_NAME}"
def gitHubUrl = "https://${gitHubOrigin}"
def NEXUS_URL = 'https://next.test.co.kr'
def gitHubAccessToken = "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"
//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"
def TAG = getTag()
def ENV = getENV()
def dockerCredentials = 'docker_ci'

pipeline {
        
    agent {
        docker {
            // ## https://github.com/shclub/dockerfile 참고
            image 'shclub/build-tool:v1.0.0'
            // ## jenkins slave 가 Docker로 뜬 경우  ( docker in docker )
            args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock -v /root/.m2:/root/.m2'
            // ## Docker hub 사용시 불필요
            //registryUrl NEXUS_URL
            //registryCredentialsId 'docker_ci'
            reuseNode true
        }
    }

    stages {
        stage('Build') {
            steps {
                script{
                    docker.withRegistry('', dockerCredentials) {
                        // ## 폐쇠망에 maven 설정이 있는 경우
                        //configFileProvider([configFile(fileId: 'icis-tr-maven_setting', variable: 'maven_settings')]) {
                            sh  """
                                pwd
                                chmod 777 ./mvnw                             
                                echo 'TAG => ' ${TAG}
                                echo 'ENV => ' ${ENV}
                                export SKAFFOLD_CACHE_ARTIFACTS=false
                                skaffold build -p ${ENV} -t ${TAG}
                            """
                        //}
                    }
                }
            }
        }
        
        stage('check out update') {
            steps{
                print "====== check out update====="
                script{      
                   sh  """
                        cd ~
                        rm -rf ./${GIT_OPS_NAME}
                   """     
                   checkout([
                       $class: 'GitSCM', branches: [[name: '*/master']],
                       userRemoteConfigs: [[url: 'https://github.com/shclub/edu13-gitops',credentialsId:'github_ci']]
                   ])
                }
            }
        }

        stage('GitOps update') {
            steps{
                print "======kustomization.yaml tag update====="
                script{
                    sh """   
                        ls
                        echo 'test' >>  test2.txt
                        git config --global --add safe.directory /var/lib/jenkins/workspace/skaffold_test
                        git remote -v
                        git config --global user.email "shclub@gmail.com"
                        git config --global user.name "shclub"                   
                        git add .
                        git commit -am 'update image tag ${TAG}'
                        git push origin master
                    """
                }
                print "git push finished !!!"
            }
        }// git config --global credential.helper store
            //git clone https://shclub:${gitHubAccessToken}@${gitOpsUrl}
            //                        git remote set-url origin https://shclub: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@github.com/shclub/edu13-gitops
//                        git remote set-url origin https://github_ci_token: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@github.com/shclub/edu13-gitops

            
                      //  git config --global user.email "shclub@gmail.com"
                       // git config --global user.name "shclub"
                       // git config --global credential.helper store
                        //git config --global -l --show-origin
            //                        git remote set-url origin https://github_ci:${gitHubAccessToken}@${gitOpsUrl}


//                                    kustomize edit set image ${GIT_ACCOUNT}/${PROJECT_NAME}:${TAG}

        stage('Cleaning up') {
                    steps {
                        //sh "docker rmi $dockerRepo"//:$BUILD_NUMBER"
                    print "clean up !!!"
                    }
         }
    }
}

def  getTag(){
    
    def TAG
    def opsBranch
    def gitBranch = "${scm.branches[0].name.split("/")[1]}"
    DATETIME_TAG = new Date().format('yyyyMMddHHmmss')

    if(gitBranch == "master" || gitBranch == "develop" ){
      TAG = "${gitBranch}-${DATETIME_TAG}"
    }else{
      TAG = "${params.Branch.replaceFirst(/^.*\//,'')}-${DATETIME_TAG}"
    }

    return TAG
}

def getENV(){

    def deployENV
    def opsBranch
    def paramBranch = "${params.Branch}"
    def gitBranch = "${scm.branches[0].name.split("/")[1]}"

    if( gitBranch == "master" ){
         deployENV = "dev"
    }else if( gitBranch == "develop" ){
         deployENV = gitBranch
    }else{
        opsBranch = paramBranch.replaceFirst(/^.*\//,'')
        deployENV =  opsBranch.replaceAll(/\-.*/,'')
    }

    return deployENV
}
