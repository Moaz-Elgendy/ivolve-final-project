// testImage(registry:, repo:, tag:, severity: 'HIGH,CRITICAL') - fails the build if Trivy finds that severity
// with an available fix (--ignore-unfixed: base-image CVEs nobody has patched yet do not block builds)
def call(Map c) {
    def severity = c.severity ?: 'HIGH,CRITICAL'
    // /tmp is a RAM-backed tmpfs (2 GiB) on this host and the Java DB download overflows it; use disk
    sh "mkdir -p \$HOME/trivy-tmp && TMPDIR=\$HOME/trivy-tmp trivy image --no-progress --exit-code 0 --ignore-unfixed --severity ${severity} ${c.registry}/${c.repo}:${c.tag}"
}
