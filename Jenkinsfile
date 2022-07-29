def PROJECT_NAME = "edu13-backend"
def GIT_OPS_NAME = "edu13-gitops"
def GIT_ACCOUNT = "shclub"
def GIT_EMAIL = "shclub@gmail.com"

def gitOpsUrl = "git@github.com:${GIT_ACCOUNT}/${GIT_OPS_NAME}"
//def gitOpsUrl = "github.com/${GIT_ACCOUNT}/${GIT_OPS_NAME}"
def gitHubOrigin = "github.com/${GIT_ACCOUNT}/${PROJECT_NAME}"
def gitHubUrl = "https://${gitHubOrigin}"
def NEXUS_URL = 'https://next.test.co.kr'
// GihtHub는 token 보이게 하는 경우 해당 토큰은 만료가 되어 사용 불가. SSH로 연결해야 함
//def gitHubAccessToken = "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"
def TAG = getTag()
def ENV = getENV()
// Jenkins Credential 에서 설정한 docker registry
def dockerCredentials = 'docker_ci'

pipeline {
        
    agent {
        docker {
            // https://github.com/shclub/dockerfile 참고
            image 'shclub/build-tool:v1.0.0'
            // 성능을 위해서 라이브러리는 jenkins 서버에 저장
            args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock -v /root/.m2:/root/.m2'
            // ocker hub 사용시 불필요. 아래는 nexus를 private docker registry 로 사용한 경우 설정
            //registryUrl NEXUS_URL
            //registryCredentialsId 'docker_ci'
            reuseNode true
        }
    }


    stages {
        stage('Build : skaffold') {
            steps {
                script{
                    docker.withRegistry('', dockerCredentials) {
                        // 폐쇄망에 maven 설정이 있는 경우
                        //configFileProvider([configFile(fileId: 'test-maven_setting', variable: 'maven_settings')]) {
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
        
      stage('GitOps update : kustomize') {
            steps{
                print "======kustomization.yaml tag update====="
                script{
                   withCredentials([sshUserPrivateKey(credentialsId: 'github_ssh',keyFileVariable: 'keyFile')]) {                       
                    def  GITHUB_SSH_KEY = readFile(keyFile)
//                    print "keyFileContent GITHUB" + "${GITHUB_SSH_KEY}"  
                    sh """   
                        cd ~
                        rm -rf ./${GIT_OPS_NAME}
                        mkdir -p .ssh         
                        set +x
                        echo  '${GITHUB_SSH_KEY}' > ~/.ssh/id_rsa
                        chmod 600 ~/.ssh/id_rsa
                        git config --global core.sshCommand "ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no "
                        git clone ${gitOpsUrl}
                        cd ./${GIT_OPS_NAME}
                        git checkout master
                        kustomize edit set image ${GIT_ACCOUNT}/${PROJECT_NAME}:${TAG}
                        git config --global user.email "${GIT_EMAIL}"
                        git config --global user.name "${GIT_ACCOUNT}"                   
                        git add .
                        git commit -am 'update image tag ${TAG}'
                        GIT_ASKPASS=true git push origin master
                    """
                      }            
                }
                        
                print "git push finished !!!"
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
