# N8N_Install_Script
Bash script para instalação do Docker Compose e do N8N no Ubuntu.

PRE-REQUISITO: PARA UTILIZAR ESSES SCRIPTS, VOCÊ JÁ DEVE TER UMA ENTRADA DE DNS APONTANDO SUBDOMINIO.DOMINIO.COM.BR PARA O ENDEREÇO DO SEU SERVIDOR DO N8N.

**Intruções para utilização desses scripts
**

1 - Crie uma pasta em seu diretório /home/user com o nome de n8n e entre nela;

cd /home/user

mkdir n8n

cd n8n/



2 - Crie o arquivo do script de instalação do Docker e copie para ele o conteúdo do arquivo installDocker.sh que está nesse repositório;

nano installDocker.sh

clique com botão direito do mouse na tela do terminal com o arquivo em edição (cola o conteúdo)

ctrl + O (para salvar)

ctrl + X (para sair)



3 - Dê permissão de execução para o arquivo criado;

chmod a+x installDocker.sh



4 - Crie o arquivo do script de configuração do N8N e copie para ele o conteúdo do arquivo configN8n.sh que está nesse repositório;

nano configN8n.sh

clique com botão direito do mouse na tela do terminal com o arquivo em edição (cola o conteúdo)

ATENÇÃO, IMPORTANTE! CASO VOCÊ JÁ TENHA ALGUM SERVIÇO UTILIZANDO AS PORTAS 80 E 443 (ALGUM WEBSERVER OU PROXY REVERSO), SERÁ NECESSÁRIO CONFIGURAR O PORT BIND NO ARQUIVO docker-compose.yaml. Você pode utilizar, por exemplo:

ports:

  - "81:81"
  
  - "444:444"

TENDO TAMBÉM O CUIDADO DE ALTERAR OS COMANDOS NO SERVIÇO DO TRAEFIK:

  -  "--entrypoints.web.address=:81"

  -  "--entrypoints.websecure.address=:444"


ctrl + O (para salvar)

ctrl + X (para sair)



5 - Dê permissão de execução para o arquivo criado;

chmod a+x configN8n.sh



6 - Execute o script de instalação do Docker;

./installDocker.sh



7 - Execute o script de configuração do N8N.

./configN8n.sh



P.S.: Todos os comandos e scripts devem ser executados com usuário padrão.

P.S.2: Durante a execução do script de instalação do docker, será solicitada a senha de root para execução do gerenciador de pacotes.
