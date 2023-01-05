pipeline{
    agent any
    options{
        
        // set time stamps on the log
        timestamps()
        
        // set gitlab connection where to sent an update
        gitLabConnection('my repo')
    }
    tools {
        // set tools to work with 
        maven "maben 3.6.2"
        jdk "java 8 kit"
    }
    stages{
        // check out and clean the workdir
        stage("checkout"){
            steps{
                echo "========checking out (loking hella fine)========"
                deleteDir()
                checkout scm
                sh "mvn clean"
                sh "git checkout main"
            }
        }

        stage("build"){
            steps{
                // starting build
                echo "========executing build========"
                withMaven {
                     configFileProvider([configFile(fileId: '0a5edd42-4379-4509-a49e-d8ba1384edeb', variable: 'set')]) {
                        sh "mvn -s ${set} verify"
                    } 
                }
            }
            post{
                success{
                    echo "========build executed successfully========"
                }
                failure{
                    echo "========build execution failed========"
                }
            }
        }
        stage("tests"){
            steps{
                echo "========executing tests========"
                

                sh """
                    cd src/test
                    docker compose up -d app
                    docker compose up tester
                """
            }
            post{
                always{
                    echo "========tests are done========"
                    // remove all tests continers on finish
                    sh "docker compose down"
                }
                success{
                    echo "========tests executed successfully========"
                }
                failure{
                    echo "========tests execution failed========"
                }
            }
        }
        stage("deploy"){
            steps{
                echo "========executing deploy========"
                
                // taging the image so i will be able to send it to the repo//
                sh "docker tag toxictypoapp:1.0-SNAPSHOT dvir-toxictypo "
                
                // publish the image to the ecr//
                script{
                    docker.withRegistry("http://644435390668.dkr.ecr.eu-west-3.amazonaws.com", "ecr:eu-west-3:aws-develeap") {
                        docker.image("dvir-toxictypo").push()
                    }
                }
                
                //deploying the new image to the production ec2//
                sh "ssh ubuntu@172.31.40.90 aws ecr get-login-password --region eu-west-3 | docker login --username AWS --password-stdin 644435390668.dkr.ecr.eu-west-3.amazonaws.com"
                sh "scp init.sh ubuntu@172.31.40.90:/home/ubuntu" 
                sh "ssh ubuntu@172.31.40.90 bash init.sh"
            }
            post{
                always{
                    echo "========deploy are done========"
                }
                success{
                    echo "========deploy executed successfully========"
                }
                failure{
                    echo "========deploy execution failed========"
                }
            }
        }
    }
    post{
        always{
            echo "========piplen ended!!!!!!!!!!!!!!!!!!========"
            
            // sending emails 
            emailext body: """Build Report
                    Project: ${env.JOB_NAME} 
                    Build Number: ${env.BUILD_NUMBER}
                    Build status is ${currentBuild.currentResult}
                    to see the full resolte enter: ${env.BUILD_URL}""",
                recipientProviders: [developers(), requestor()],
                subject: 'tests resulte: Project name -> ${JOB_NAME}',
                attachLog: true
        }
        success{
            echo "========pipeline executed successfully ========"
            
            // updating the git status to the git reposetory 
            updateGitlabCommitStatus name: "all good", state: "success" 
        }
        failure{
            echo "========pipeline execution failed========"
            
            // updating the git status to the git reposetory 
            updateGitlabCommitStatus name: "error", state: "failed" 
        }
    }
}