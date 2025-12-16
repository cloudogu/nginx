@Library([
  'pipe-build-lib',
  'ces-build-lib',
  'dogu-build-lib'
]) _

def pipe = new com.cloudogu.sos.pipebuildlib.DoguPipe(this, [
    doguName            : "nginx",
    shellScripts        : '''
                            ./resources/startup.sh 
                            ./nginx-build/build.sh
                          ''',
    checkMarkdown       : true,
    cypressImage        : 'cypress/included:13.14.0',
    runIntegrationTests : true,
    dependedDogus       : ['cas']

])
com.cloudogu.ces.dogubuildlib.EcoSystem ecoSystem = pipe.ecoSystem

pipe.setBuildProperties()
pipe.addDefaultStages()

pipe.insertStageAfter("trivy scan","Prepare integration tests") {
    setIntegrationTestKeys(ecoSystem)
}


pipe.insertStageAfter("upgrade dogu","Prepare integration tests") {
    setIntegrationTestKeys(ecoSystem)
    ecoSystem.restartDogu("nginx")
}

pipe.run()

void setIntegrationTestKeys(ecoSystem){
  // static HTML config
  ecoSystem.vagrant.ssh "sudo cp /dogu/integrationTests/privacy_policies.html /var/lib/ces/nginx/volumes/customhtml/"
  ecoSystem.vagrant.ssh '''etcdctl set config/nginx/externals/privacy_policies '{\\"DisplayName\\":\\"Privacy Policies\\",\\"Description\\":\\"Contains information about the privacy policies enforced by our company\\",\\"Category\\":\\"Information\\",\\"URL\\":\\"/static/privacy_policies.html\\"}' '''
  // etcd key for support entries
  ecoSystem.vagrant.ssh '''etcdctl set /config/_global/disabled_warpmenu_support_entries '[\\"platform\\", \\"aboutCloudoguToken\\"]' '''
}
