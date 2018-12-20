pipeline {
  agent slave

  stages {
    stage('Build') {
      steps {
        sh "go build main.go"
      }
    }
    stage('Test') {
      steps {
        sh "go test"
      }
    }
    stage('Deploy') {
      steps {
      	sh "./createdeb.sh"
	sh "lintian package.deb web-calc_1.0-1_all.deb"        
	sh "dpkg -i web-calc_1.0-1_all.deb "
      }
    }
  }
}
