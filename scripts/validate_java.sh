#!/bin/bash

java_bin=$1

JAVA_RUNTIME_VERSION=$($java_bin -XshowSettings:properties -version 2>&1 | grep -F "java.runtime.version =" | awk '{split($0,tokens,"= "); print tokens[2]}')
if (( $? != 0 ))
then
   echo "Unable to determine the java.runtime.version from the Java settings." >&2
   exit 1
fi

JAVA_VENDOR=$($java_bin -XshowSettings:properties -version 2>&1 | grep -F "java.vendor =" | awk '{split($0,tokens,"= "); print tokens[2]}')
if (( $? != 0 ))
then
   echo "Unable to determine the java.vendor from the Java settings." >&2
   exit 1
fi

JAVA_VER=$($java_bin -XshowSettings:properties -version 2>&1 | grep -F java.version | awk '{split($0,tokens,"= "); print tokens[2]}')
if (( $? != 0 ))
then
   echo "Unable to determine the java.version from the Java settings." >&2
   exit 1
fi

if [[ $JAVA_VER != 1.8.0_* ]]
then
   echo $java_bin is not Java 8 >&2
   exit 1
fi

JAVA_VERSION_UPDATE=${JAVA_VER##*_}
JAVA_VERSION_UPDATE=${JAVA_VERSION_UPDATE%%-*}

case "$JAVA_VENDOR" in
   "Azul Systems, Inc.")
      MIN_VERSION_AZUL=212
      if (( JAVA_VERSION_UPDATE < MIN_VERSION_AZUL ))
      then
         echo "$java_bin ($JAVA_RUNTIME_VERSION) is too old. Java must be 1.8.0_$MIN_VERSION_AZUL or greater." >&2
         exit 1
      fi
      ;;

   "IcedTea")
      MIN_VERSION_ICEDTEA=212
      if (( JAVA_VERSION_UPDATE < MIN_VERSION_ICEDTEA ))
      then
         echo "$java_bin ($JAVA_RUNTIME_VERSION) Java must be 1.8.0_$MIN_VERSION_ICEDTEA or greater." >&2
         exit 1
      fi
      ;;

   "Oracle Corporation")
      JAVA_RUNTIME_NAME=$($java_bin -XshowSettings:properties -version 2>&1 | grep -F java.runtime.name | awk '{split($0,tokens,"= "); print tokens[2]}')
      if (( $? != 0 ))
      then
         echo "Unable to determine the java.runtime.name from the Java settings." >&2
         exit 1
      fi

      MIN_VERSION_ORACLE=161
      MIN_VERSION_ORACLE_OPENJDK=121

      [[ $JAVA_RUNTIME_NAME = *OpenJDK* ]] && MIN_VERSION=$MIN_VERSION_ORACLE_OPENJDK || MIN_VERSION=$MIN_VERSION_ORACLE
      if (( JAVA_VERSION_UPDATE < MIN_VERSION ))
      then
         echo "$java_bin ($JAVA_RUNTIME_VERSION) is too old. Java must be 1.8.0_$MIN_VERSION or greater." >&2
         exit 1
      fi
      ;;

   *)
      echo "Java vendor '$JAVA_VENDOR' is not supported. Supported Java vendors are 'Oracle Corporation', 'IcedTea' and 'Azul Systems, Inc.'."
      if [ -z "$DISABLE_JAVA_VALIDATION" ]
      then
          echo "Set DISABLE_JAVA_VALIDATION to use Java vendor '$JAVA_VENDOR' version $JAVA_RUNTIME_VERSION"
          exit 1
      fi
esac
