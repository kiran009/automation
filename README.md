Tertio Automation

Java Projects
1. Start CMSynergy session as build_mgr
2. Input project name
3. Input server name
4. Go to /data/ccmbm/Provident_Java-7.7.0
5. Run reconfigure
6. Execute "gmake clean all"

Other Platform Projects
1. Start CMSynergy session as build_mgr
2. Input Dev project name
3. Input server name
4. Go to /data/ccmbm/
5. Run reconfigure
6. Execute "gmake clean all"
7. Input Delivery project name
8. Go to project root
9. Run reconfigure
10. Execute "gmake clean deliver"
11. Copy deliverables:

cp /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/tertio.tar /data/releases/tertio/7.7.0_RC/server/rhel6/latest/NotTested/tertio770RHEL6_201505061206.tar
cp /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/tertio.txt /data/releases/tertio/7.7.0_RC/server/rhel6/latest/NotTested/tertio770RHEL6_201505061206.txt
cp /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/CoreZSLPackage_1-0-0.Z  /data/releases/tertio/7.7.0_RC/server/rhel6/latest/NotTested/CoreZSLPackage_1-0-0_201505061206.Z
cp /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/gpsretrieve  /data/releases/tertio/7.7.0_RC/server/rhel6/latest/NotTested/gpsretrieve_201505061206
cp /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/adk.tar /data/releases/tertio/7.7.0_RC/adk/rhel6/latest/NotTested/adk770RHEL6_201505061206.tar
cp /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/testbench.tar /data/releases/tertio/7.7.0_RC/testbench/rhel6/latest/NotTested/testbench770RHEL6_201505061206.tar
cd /opt/tertio_adk/
mkdir 7.7.0_build11
cd 7.7.0_build11
tar -xf /data/ccmbm/provident/Provident_Delivery-RHEL6_7.7.0/Provident_Delivery/build/adk.tar
mv tertio-adk-7.7.0/* ./
rm -rf tertio-adk-7.7.0


# DSA

fur 4.0
linux platform
add folder
add tasks

Platforms:
RHEL5

1. Dev project
2. Reconfigure
3. cd $devproject/DSA_FUR_Dev
4. gmake clean all

1. Go to Delivery project
2. Reconfigure
3. Parse the fileplacement
4. tar cvf <tar name> 
