def PROJECT_NAME = "edu13"
def GIT_OPS_NAME = "edu13-gitops"
def GIT_ACCOUNT = "shclub"
def gitOpsUrl = "github.com/${GIT_ACCOUNT}/${GIT_OPS_NAME}.git"
def gitHubOrigin = "github.com/${GIT_ACCOUNT}/${PROJECT_NAME}.git"
def gitHubUrl = "https://${gitHubOrigin}"
def NEXUS_URL = 'https://next.test.co.kr'
def gitHubAccessToken = "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"
def TAG = getTag()
def ENV = getENV()
def dockerCredentials = 'docker_ci'

pipeline {
        
    agent {
        docker {
            // ## https://github.com/shclub/dockerfile 참고
            image 'shclub/build-tool:v1.0.0'
            // ## jenkins slave 가 Docker로 뜬 경우  ( docker in docker )
            args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'
            // ## Docker hub 사용시 불필요
            //registryUrl NEXUS_URL
            //registryCredentialsId 'docker_ci'
            //reuseNode true
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
                                skaffold build -p ${ENV} -t ${TAG}
                            """
                        //}
                    }
                }
            }
        }

        stage('GitOps update') {
            steps{
                print "======kustomization.yaml tag update====="
                script{
                    sh """   
                        cd ~
                        rm -rf ./${GIT_OPS_NAME}
                        git clone https://shclub:${gitHubAccessToken}@github.com/${gitOpsUrl}.git
                        cd ./${GIT_OPS_NAME}
                        git checkout ${ENV}
                        kustomize edit set image ${GIT_ACCOUNT}/${PROJECT_NAME}:${TAG}
                        git config --global user.email "shclub@gmail.com"
                        git config --global user.name "shclub"
                        git add .
                        git commit -am 'update image tag ${TAG}'
                        git push origin ${ENV}
                    """
                }
                print "git push finished !!!"
            }
        }

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
