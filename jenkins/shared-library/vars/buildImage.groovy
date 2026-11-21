// buildImage(registry: '...', repo: 'ivolve-frontend', context: 'app/frontend', tag: 'abc123')
def call(Map c) {
    sh "docker build -t ${c.registry}/${c.repo}:${c.tag} ${c.context}"
}
