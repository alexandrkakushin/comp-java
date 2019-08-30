#!/bin/bash
# Скрипт для сборки конфигурации "Компоненты Java"

clear

#BASEDIR="$(pwd)"
BASEDIR="/tmp/comp-java"

GIT_REPOSITORIES='https://github.com/alexandrkakushin'

COMP_LOGGER='logger'
COMP_SFTPCLIENT='sftpclient'
COMP_JMSCLIENT='jmsclient'
COMP_REGEX='regex'
COMP_EMAILVALIDATOR='emailvalidator'
COMP_SSHCLIENT='sshclient'
COMP_IMPORTTABLE='importtable'
COMP_LDAPCLIENT='ldapclient'

COMPONENTS="${COMP_LOGGER} ${COMP_SFTPCLIENT} ${COMP_JMSCLIENT} ${COMP_REGEX} ${COMP_EMAILVALIDATOR} ${COMP_SSHCLIENT} ${COMP_IMPORTTABLE} ${COMP_LDAPCLIENT}"
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
for component in ${COMPONENTS}
do
  echo "===== ${component} ====="
  clone_pull_repository ${JAVA_SOURCE_DIR} "comp-java-${component}" "${GIT_REPOSITORIES}/comp-java-${component}.git"
done

echo '\nBuilding...'
for component in ${COMPONENTS}
do  
  echo "===== ${component} ====="
  mvn --quiet clean install -f "comp-java-${component}"
  JAR_FILE="${JAVA_SOURCE_DIR}/comp-java-${component}/target/${component}-jar-with-dependencies.jar"
  TEMPLATE_FILE="${TEMPLATES_DIR}/${component}/Ext/Template.bin"
  if [ -e ${JAR_FILE} ]
  then
    if ! [ -e "${TEMPLATES_DIR}/${component}" ]
    then
      mkdir "${TEMPLATES_DIR}/${component}"
      if ! [ -e "${TEMPLATES_DIR}/${component}/Ext" ]
      then
        mkdir "${TEMPLATES_DIR}/${component}/Ext"
      fi
    fi
    cp ${JAR_FILE} ${TEMPLATE_FILE}
  else
    echo "Jar-file not found... ${JAR_FILE}"
  fi    
done

echo 'Complete'

exit 0