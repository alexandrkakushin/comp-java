#!/bin/bash
# Скрипт для сборки подсистемы "Компоненты Java"

clear

TARGET_DIR="$(pwd)"/target
if [ ! -e ${TARGET_DIR} ]
then
  mkdir ${TARGET_DIR} 
fi

GIT_REPOSITORIES='https://github.com/alexandrkakushin'

COMP_LOGGER='logger'
COMP_SFTPCLIENT='sftpclient'
COMP_JMSCLIENT='jmsclient'
COMP_REGEX='regex'
COMP_EMAILVALIDATOR='emailvalidator'
COMP_EXCELCLIENT="excelclient"

GIT_COMPJAVA="${GIT_REPOSITORIES}/comp-java.git"

TEMPLATES_DIR="${TARGET_DIR}/comp-java/Catalogs/КомпонентыJava/Templates"
JAVA_SOURCE_DIR="${TARGET_DIR}/java-source"

clone_repository(){
  LOCAL_BASEBIR=$1
  NAME_REPOSITORY=$2
  REMOTE_REPOSITORY=$3
    
  cd ${LOCAL_BASEBIR}
    
  LOCAL_REPOSITORY="${LOCAL_BASEBIR}/${NAME_REPOSITORY}"

  if [ -e ${LOCAL_REPOSITORY} ]; then
      rm -rf ${LOCAL_REPOSITORY}
  fi
  
  git clone --quiet ${REMOTE_REPOSITORY}
}

echo "Cloning repositories:"

# Клонирование основного репозитория
echo " - 1C:Enterprise configuration"
clone_repository ${TARGET_DIR} "comp-java" ${GIT_COMPJAVA}

# Клонирование репозиториев компонент, сборка
echo " - Java-components" 
if [ ! -e ${JAVA_SOURCE_DIR} ]
then
  mkdir ${JAVA_SOURCE_DIR} 
fi
for comp in ${COMP_LOGGER} ${COMP_SFTPCLIENT} ${COMP_JMSCLIENT} ${COMP_REGEX} ${COMP_EMAILVALIDATOR} ${COMP_EXCELCLIENT}
do
  echo "   - ${comp}"
  clone_repository ${JAVA_SOURCE_DIR} "comp-java-${comp}" "${GIT_REPOSITORIES}/comp-java-${comp}.git"
done

echo '\nBuilding...'
for component in ${COMP_LOGGER} ${COMP_SFTPCLIENT} ${COMP_JMSCLIENT} ${COMP_REGEX} ${COMP_EMAILVALIDATOR} ${COMP_EXCELCLIENT};
do
  echo " - ${component}"  
  
  mvn --quiet clean install -f "comp-java-${component}"
  JAR_FILE="${JAVA_SOURCE_DIR}/comp-java-${component}/target/${component}-jar-with-dependencies.jar"
  
  TEMPLATE_DIR_EXT="${TEMPLATES_DIR}/${component}/Ext"
  if [ ! -e ${TEMPLATE_DIR_EXT} ] 
  then
    mkdir -p ${TEMPLATE_DIR_EXT}
  fi
  
  TEMPLATE_BIN="${TEMPLATE_DIR_EXT}/Template.bin"
  
  if [ -e ${JAR_FILE} ]
  then
    cp ${JAR_FILE} ${TEMPLATE_BIN}
  else
    echo "Jar-file not found... ${JAR_FILE}"
  fi

  echo    
done

echo 'FINISH'

exit 0
