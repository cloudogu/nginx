#!groovy
@Library(['github.com/cloudogu/dogu-build-lib@v3.2.0', 'github.com/cloudogu/ces-build-lib@4.2.0']) _
import com.cloudogu.ces.dogubuildlib.*
import com.cloudogu.ces.cesbuildlib.*

node('vagrant') {
    String doguName = "nginx"
    timestamps{
        properties([
                // Keep only the last x builds to preserve space
                buildDiscarder(logRotator(numToKeepStr: '10')),
                // Don't run concurrent builds for a branch, because they use the same workspace directory
                disableConcurrentBuilds(),
                // Parameter to activate dogu upgrade test on demand
                parameters([
                        booleanParam(defaultValue: true, description: 'Enables cypress to record video of the integration tests.', name: 'EnableVideoRecording'),
                        booleanParam(defaultValue: true, description: 'Enables cypress to take screenshots of failing integration tests.', name: 'EnableScreenshotRecording'),
                        booleanParam(defaultValue: false, description: 'Test dogu upgrade from latest release or optionally from defined version below', name: 'TestDoguUpgrade'),
                        string(defaultValue: '', description: 'Old Dogu version for the upgrade test (optional; e.g. 3.23.0-1)', name: 'OldDoguVersionForUpgradeTest'),
                        choice(name: 'TrivySeverityLevels', choices: [TrivySeverityLevel.CRITICAL, TrivySeverityLevel.HIGH_AND_ABOVE, TrivySeverityLevel.MEDIUM_AND_ABOVE, TrivySeverityLevel.ALL], description: 'The levels to scan with trivy', defaultValue: TrivySeverityLevel.CRITICAL),
                        choice(name: 'TrivyStrategy', choices: [TrivyScanStrategy.UNSTABLE, TrivyScanStrategy.FAIL, TrivyScanStrategy.IGNORE], description: 'Define whether the build should be unstable, fail or whether the error should be ignored if any vulnerability was found.', defaultValue: TrivyScanStrategy.UNSTABLE),
                ])
        ])

        EcoSystem ecoSystem = new EcoSystem(this, "gcloud-ces-operations-internal-packer", "jenkins-gcloud-ces-operations-internal")
        Git git = new Git(this, "cesmarvin")
        git.committerName = 'cesmarvin'
        git.committerEmail = 'cesmarvin@cloudogu.com'
        GitFlow gitflow = new GitFlow(this, git)
        GitHub github = new GitHub(this, git)
        Changelog changelog = new Changelog(this)

        stage('Checkout') {
            checkout scm
        }

        stage('Lint') {
            Dockerfile dockerfile = new Dockerfile(this)
            dockerfile.lint()
        }

        stage('Check Markdown Links') {
            Markdown markdown = new Markdown(this, "3.11.0")
            markdown.check()
        }

        stage('Shellcheck'){
            shellCheck('./resources/startup.sh ./nginx-build/build.sh')
        }

        try {

            stage('Provision') {
                // change namespace to prerelease_namespace if in develop-branch
                if (gitflow.isPreReleaseBranch()) {
                    sh "make prerelease_namespace"
                }
                ecoSystem.provision("/dogu")
            }

            stage('Setup') {
                ecoSystem.loginBackend('cesmarvin-setup')
                ecoSystem.setup()
            }

            stage('Build') {
                // purge nginx from official namespace to prevent conflicts while building prerelease_official/nginx
                if (gitflow.isPreReleaseBranch()) {
                    ecoSystem.purgeDogu("nginx")
                }
                ecoSystem.build("/dogu")
            }

            stage('Trivy scan') {
                ecoSystem.copyDoguImageToJenkinsWorker("/dogu")
                Trivy trivy = new Trivy(this)
                trivy.scanDogu(".", params.TrivySeverityLevels, params.TrivyStrategy)
                trivy.saveFormattedTrivyReport(TrivyScanFormat.TABLE)
                trivy.saveFormattedTrivyReport(TrivyScanFormat.JSON)
                trivy.saveFormattedTrivyReport(TrivyScanFormat.HTML)
            }

            stage('Prepare integration tests') {
                setIntegrationTestKeys(ecoSystem)
            }

            stage('Verify') {
                ecoSystem.verify("/dogu")
            }

            stage('Wait for dependencies') {
                timeout(15) {
                    ecoSystem.waitForDogu("cas")
                }
            }

            stage('Integration tests') {
                ecoSystem.runCypressIntegrationTests([cypressImage     : "cypress/included:13.14.0",
                                                      enableVideo      : params.EnableVideoRecording,
                                                      enableScreenshots: params.EnableScreenshotRecording])
            }

            if (params.TestDoguUpgrade != null && params.TestDoguUpgrade) {
                stage('Upgrade dogu') {
                    ecoSystem.upgradeFromPreviousRelease(params.OldDoguVersionForUpgradeTest, doguName)
                }

                stage('Prepare integration tests - After Upgrade') {
                  setIntegrationTestKeys(ecoSystem)
                  ecoSystem.restartDogu("nginx")
                }

                stage('Wait for dependencies - After Upgrade') {
                    timeout(15) {
                        ecoSystem.waitForDogu("cas")
                    }
                }

                stage('Integration Tests - After Upgrade'){
                    // Run integration tests again to verify that the upgrade was successful
                    ecoSystem.runCypressIntegrationTests([cypressImage     : "cypress/included:13.14.0",
                                                          enableVideo      : params.EnableVideoRecording,
                                                          enableScreenshots: params.EnableScreenshotRecording])
                }
            }
            if (gitflow.isReleaseBranch()) {
                String releaseVersion = git.getSimpleBranchName()

                stage('Finish Release') {
                    gitflow.finishRelease(releaseVersion)
                }

                stage('Push Dogu to registry') {
                    ecoSystem.push("/dogu")
                }

                stage ('Add Github-Release'){
                    github.createReleaseWithChangelog(releaseVersion, changelog)
                }
            } else if (gitflow.isPreReleaseBranch()) {
                // push to registry in prerelease_namespace
                stage('Push Prerelease Dogu to registry') {
                    ecoSystem.pushPreRelease("/dogu")
                }
            }

        } finally {
            stage('Clean') {
                ecoSystem.destroy()
            }
        }
    }
}

void setIntegrationTestKeys(ecoSystem){
  // static HTML config
  ecoSystem.vagrant.ssh "sudo cp /dogu/integrationTests/privacy_policies.html /var/lib/ces/nginx/volumes/customhtml/"
  ecoSystem.vagrant.ssh '''etcdctl set config/nginx/externals/privacy_policies '{\\"DisplayName\\":\\"Privacy Policies\\",\\"Description\\":\\"Contains information about the privacy policies enforced by our company\\",\\"Category\\":\\"Information\\",\\"URL\\":\\"/static/privacy_policies.html\\"}' '''
  // etcd key for support entries
  ecoSystem.vagrant.ssh '''etcdctl set /config/_global/disabled_warpmenu_support_entries '[\\"platform\\", \\"aboutCloudoguToken\\"]' '''
}
