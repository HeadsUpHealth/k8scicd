def POD_LABEL = "buildpod-${UUID.randomUUID().toString()}"
podTemplate(label: POD_LABEL, cloud: 'kubernetes', 
containers: [
    containerTemplate(name: 'build', image: 'golang', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'test', image: 'golang', ttyEnabled: true, command: 'cat'),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl', command: 'cat', ttyEnabled: true)
  ],
volumes: [
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')
  ]) {

    node(POD_LABEL) {

      withEnv(['registry=sphenrie/k8scicd-forked',
            'GOCACHE=/tmp']) {

        stage('build a go project') {
            container('build') {

                checkout scm

                // Create our project directory.
                sh 'cd ${GOPATH}/src'
                sh 'mkdir -p ${GOPATH}/src/hello-world'
                // Copy all files in our Jenkins workspace to our project directory.                
                sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/hello-world'
                // Build the app.
                sh 'go build'    
            }
        }

        stage('Test a Golang project') {
            container('test') {
                // Create our project directory.
                sh 'cd ${GOPATH}/src'
                sh 'mkdir -p ${GOPATH}/src/hello-world'
                // Copy all files in our Jenkins workspace to our project directory.                
                sh 'cp -r ${WORKSPACE}/* ${GOPATH}/src/hello-world'
                // Remove cached test results.
                sh 'go clean -cache'
                // Run Unit Tests.
                sh 'go test ./... -v -short' 
                }

        }

        stage('Publish a Golang project') {
            container('docker') {

                def appimage = docker.build( registry + ":$BUILD_NUMBER", "--network host -f Dockerfile .)
                docker.withRegistry( 'https://registry.app.headsuphealth.com', '1f06cab3-1ac3-4ac5-8075-4ca8676f4791' ) {
                    appimage.push()
                    //appimage.push('latest')
                }
            }
        }

        stage('Deploy a Golang project') {
            container('kubectl')  {  
                def image_id = registry + ":$BUILD_NUMBER"
                sh "kubectl set image deployment hello-deployment go-app=${image_id} -n develop --record"
            }
        }
      }
    }
}



