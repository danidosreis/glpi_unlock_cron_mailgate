# glpi_unlock_cron_mailgate
Script desenvolvido para destravar automaticamente a cron mailgate do GLPI

O Glpi é uma ferramenta ITSM que contém uma cron chamada mailgate, responsável pela integração de e-mails à ferramenta. 

Foi idenfificado diversos travamentos dessa cron, tendo que muitas realizar procedimentos manuais para reestabelece-la, impactando nas tarefas do dia a dia da operação e no atraso das integrações dos e-mails. 

Por isso foi criado o script "script_unlockmailgate.sh" que é executado de tempos em tempos identificando a funcionalidade da cron, e, quando necessário realizando o seu reestabelecimento de forma automática e transparente.
