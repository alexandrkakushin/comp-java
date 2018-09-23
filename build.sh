#!/bin/bash
# Скрипт для сборки подсистемы "Компоненты Java"

clear

BASEDIR="$(pwd)"

GIT_REPOSITORIES='https://github.com/alexandrkakushin'

COMP_LOGGER='logger'
COMP_SFTPCLIENT='sftpclient'
COMP_JMSCLIENT='jmsclient'
COMP_REGEX='regex'
COMP_EMAILVALIDATOR='emailvalidator'
COMP_SSHCLIENT='sshclient'

GIT_COMPJAVA="${GIT_REPOSITORIES}/comp-java.git"

TEMPLATES_DIR="${BASEDIR}/comp-java/Catalogs/КомпонентыJava/Templates"
JAVA_SOURCE_DIR="${BASEDIR}/java-source"

clone_pull_repository(){
  LOCAL_BASEBIR=$1
  NAME_REPOSITORY=$2
  REMOTE_REPOSITORY=$3
    
  cd ${LOCAL_BASEBIR}
    
  LOCAL_REPOSITORY="${LOCAL_BASEBIR}/${NAME_REPOSITORY}"

  echo ${LOCAL_REPOSITORY}  
  if [ -e ${LOCAL_REPOSITORY} ]; then
    if [ -e "${LOCAL_REPOSITORY}/.git" ]; then	
      git pull
    else
      rm -R ${LOCAL_REPOSITORY}
      git clone ${REMOTE_REPOSITORY}
	  fi
  else
    git clone ${REMOTE_REPOSITORY}
  fi
}

# Клонирование основного репозитория
echo "Clone/pull COMP-JAVA (1C:Enterprise) repository"
clone_pull_repository ${BASEDIR} "comp-java" ${GIT_COMPJAVA}
#git clone ${GIT_COMPJAVA}

# Клонирование репозиториев компонент, сборка
echo "\nClone/pull Java-components repository" 
if [ ! -e ${JAVA_SOURCE_DIR} ]
then
  mkdir ${JAVA_SOURCE_DIR} 
fi
for comp in ${COMP_LOGGER} ${COMP_SFTPCLIENT} ${COMP_JMSCLIENT} ${COMP_REGEX} ${COMP_EMAILVALIDATOR} ${COMP_SSHCLIENT}
do
  echo ${comp}
  clone_pull_repository ${JAVA_SOURCE_DIR} "comp-java-${comp}" "${GIT_REPOSITORIES}/comp-java-${comp}.git"
done

echo '\nBuilding...'
for component in ${COMP_LOGGER} ${COMP_SFTPCLIENT} ${COMP_JMSCLIENT} ${COMP_REGEX} ${COMP_EMAILVALIDATOR} ${COMP_SSHCLIENT};
do  
  mvn clean install -f "comp-java-${component}"
  JAR_FILE="${JAVA_SOURCE_DIR}/comp-java-${component}/target/${component}-jar-with-dependencies.jar"
  TEMPLATE_FILE="${TEMPLATES_DIR}/${component}/Ext/Template.bin"
  if [ -e ${JAR_FILE} ]
  then
    cp ${JAR_FILE} ${TEMPLATE_FILE}
  else
    echo "Jar-file not found... ${JAR_FILE}"
  fi    
done

echo 'Complete'

exit 0