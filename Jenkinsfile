#!groovy
@Library(['github.com/cloudogu/dogu-build-lib@v2.0.0', 'github.com/cloudogu/ces-build-lib@1.64.1']) _
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
                        string(defaultValue: '', description: 'Old Dogu version for the upgrade test (optional; e.g. 3.23.0-1)', name: 'OldDoguVersionForUpgradeTest')
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
            lintDockerfile()
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
                ecoSystem.provision("/dogu");
            }

            stage('Setup') {
                ecoSystem.loginBackend('cesmarvin-setup')
                ecoSystem.setup()
            }

            stage('Build') {
                ecoSystem.build("/dogu")
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
                ecoSystem.runCypressIntegrationTests([cypressImage     : "cypress/included:8.6.0",
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
                    ecoSystem.runCypressIntegrationTests([cypressImage     : "cypress/included:8.6.0",
                                                          enableVideo      : params.EnableVideoRecording,
                                                          enableScreenshots: params.EnableScreenshotRecording])
                }
            }
            if (gitflow.isReleaseBranch()) {
                String releaseVersion = git.getSimpleBranchName();

                stage('Finish Release') {
                    gitflow.finishRelease(releaseVersion)
                }

                stage('Push Dogu to registry') {
                    ecoSystem.push("/dogu")
                }

                stage ('Add Github-Release'){
                    github.createReleaseWithChangelog(releaseVersion, changelog)
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
