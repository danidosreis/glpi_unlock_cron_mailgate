#!/bin/bash

### Script desenvolvido para destravar automaticamente a cron mailgate do GLPI ###

# Variáveis
OPTION="$1"
MYSQL=$(which mysql)
DATABASE=glpi
USER='glpi'
PASS='senha'
IP=x.x.x.x
DBCONNECT=$(echo $MYSQL -h$IP -u$USER -p$PASS $DATABASE)
LOG_GLPI=/var/log/glpi
LOG_SCRIPT_ERROR=/var/log/script_unlockmailgate/unlockmailgate-erro.log
LOG_SCRIPT_OK=/var/log/script_unlockmailgate/unlockmailgate-ok.log

# Query que verifica última execução da Cron mailgate e o status

QUERY=`$DBCONNECT -B -N -e "select state, lastrun from glpi_crontasks where name like \"mailgate\"" 2> /dev/null`

# Guarda em variáveis o status, lastrun, lastrun em unixtime da cron mailgate, a hora atual e a diferença entre a hora atual e a ultima execução da cron.

STATE_MAILGATE=`echo "$QUERY" | awk '{print $1}'`
HORA_MAILGATE=`echo "$QUERY" | awk '{print $2, $3}'`
LASTRUN_MAILGATE=`date -d "$HORA_MAILGATE" "+%s"`
HORA_ATUAL=`date "+%s"`
DIFERENCA=`echo $(($HORA_ATUAL - $LASTRUN_MAILGATE))`

# Compara se a diferença está maior que 2 minutos(120) e se o status da mailgate está executando(2)
# Se positivo é alterado o status da mailgate para aguardando(1) e guarda os logs.

if [ $DIFERENCA -ge 150 ] & [ $STATE_MAILGATE -eq 2 ]; then
        $DBCONNECT -B -N -e "update glpi_crontasks set state = '1' where name = 'mailgate'" 2> /dev/null
        HORA_PROBLEMA=`cat $LOG_GLPI/sql-errors.log | grep -A15 max_allowed_packet | grep ddc027.agilitynetworks.com.br | tail -1 | awk '{print $1, $2}'`
        ID_OFENSOR=$(cat $LOG_GLPI/sql-errors.log | grep glpi_queuedmails | tail -1 | egrep -o "VALUES \(\\\'Ticket\\\',\\\'[0-9]{10}" | sed "s/\\\'//g" | awk -F',' '{print $2}')
        echo `date '+%F %T'` >> $LOG_SCRIPT_ERROR
        echo "Última ocorrência: $HORA_PROBLEMA" >> $LOG_SCRIPT_ERROR
        echo "Chamado ofensor: $ID_OFENSOR" >> $LOG_SCRIPT_ERROR
        echo ' ' >> $LOG_SCRIPT_ERROR
else
        echo `date '+%F %T'` >> $LOG_SCRIPT_OK
        echo "A cron mailgate está operando normalmente" >> $LOG_SCRIPT_OK
        echo "" >> $LOG_SCRIPT_OK
fi
