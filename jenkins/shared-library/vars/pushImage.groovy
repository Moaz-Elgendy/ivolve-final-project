// pushImage(registry:, repo:, tag:, region: 'eu-west-1') - authenticates with the instance IAM role
def call(Map c) {
    def region = c.region ?: 'eu-west-1'
    sh """
        aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${c.registry}
        docker push ${c.registry}/${c.repo}:${c.tag}
    """
}
