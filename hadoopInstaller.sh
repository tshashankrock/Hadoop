#unzip the first input on second input location.
tar xf $1 -C $2
echo "$1 untared"
suffix=".tar.gz"
y=$(basename $1)
relativePath="$2${y%"$suffix"}"
Pwd=$(pwd)
Pwd="$Pwd/$relativePath"
#add in bashrc
suffix="/bin/javac"
java_home=$(readlink -f $(which javac))
java_home=${java_home%"$suffix"}
echo $java_home
#bashrcString=
echo -e "export HADOOP_INSTALL=$Pwd \n export JAVA_HOME=$java_home" >> ~/.bashrc
bashrcString="export PATH=\$PATH:\$HADOOP_INSTALL/bin \n
export PATH=\$PATH:\$HADOOP_INSTALL/sbin \n
export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL \n
export HADOOP_COMMON_HOME=\$HADOOP_INSTALL \n
export HADOOP_HDFS_HOME=\$HADOOP_INSTALL \n
export YARN_HOME=\$HADOOP_INSTALL"

echo -e $bashrcString >> ~/.bashrc
source ~/.bashrc
hadoopFiles="$Pwd/etc/hadoop"
hadoopEnvLoc="$hadoopFiles/hadoop-env.sh"
sed -i "s@export JAVA_HOME=\${JAVA_HOME}@export JAVA_HOME=$java_home@" $hadoopEnvLoc
echo "hadoop-env.h done"
coreSite="<property> \
<name>fs.default.name<\/name><value>hdfs:\/\/localhost:9000<\/value><\/property><\/configuration>"
coreSiteLoc="$hadoopFiles/core-site.xml"
sed -i "s@</configuration>@$coreSite@" $coreSiteLoc
echo "core-site.xml done"
yarnSite="<property> \
 <name>yarn.nodemanager.aux-services<\/name> \
 <value>mapreduce_shuffle<\/value> \
<\/property> \
<property> \
 <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class<\/name> \
 <value>org.apache.hadoop.mapred.ShuffleHandler<\/value> \
<\/property><\/configuration>"
yarnSiteLoc="$hadoopFiles/yarn-site.xml"
sed -i "s@</configuration>@$yarnSite@" $yarnSiteLoc
echo "yarn-site.xml done"
mv "$hadoopFiles/mapred-site.xml.template" "$hadoopFiles/mapred-site.xml"
mapredSite="<property> \
 <name>mapreduce.framework.name<\/name> \
 <value>yarn<\/value> \
<\/property><\/configuration>"
mapredSiteLoc="$hadoopFiles/mapred-site.xml"
sed -i "s@</configuration>@$mapredSite@" $mapredSiteLoc
echo "mared-site.xml done"
mkdir -p ~/mydata/hdfs/namenode
mkdir -p ~/mydata/hdfs/datanode
hdfsSite="<property> \
 <name>dfs.replication<\/name> \
 <value>1<\/value> \
<\/property> \
<property> \
 <name>dfs.namenode.name.dir<\/name> \
 <value>file:\/home\/$(whoami)\/mydata\/hdfs\/namenode<\/value> \
<\/property> \
<property> \
 <name>dfs.datanode.data.dir<\/name> \
 <value>file:\/home\/$(whoami)\/mydata\/hdfs\/datanode<\/value> \
<\/property></configuration>"
hdfsSiteLoc="$hadoopFiles/hdfs-site.xml"
sed -i "s@</configuration>@$hdfsSite@" $hdfsSiteLoc
echo "hdfs-site done"
