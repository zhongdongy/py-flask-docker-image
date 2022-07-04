node {
  def commitId
  def imageOutput
  stage('Preparation') {
    checkout scm
    sh 'git rev-parse --short HEAD > .git/commit-id'
    commitId = readFile('.git/commit-id').trim()
  }

  stage('Build') {
    imageOutput = docker.build("vikily/py-upgrade-service:${commitId}")
    println('Build complete')
  }

  stage('Publish') {
      docker.withRegistry('https://index.docker.io/v1/', 'docker-vikily') {
        imageOutput.push(commitId)
        imageOutput.push('latest')
      }
  }

  stage('Clean') {
    sh "docker rmi ${imageOutput.id}"
  }
}
