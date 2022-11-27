#!/bin/bash
#
#############################################################################################
# Monitor de energía para apagado seguro, para laptops o servidores que usen baterias 
# y la información sea gestionada por APCI
#
# Programador: Eidy Estupiñan Varona <eidyev@gmail.com>
# MIT License
#
# Requerimientos de software: APCI , AWK
# Instalar en Debian, Ubuntu o deribados
#     apt install acpi awk
#
# Para usar descargar este archivo y ubicarlo en /srv/batery-mon.sh 
# Darle permisos de ejecución  
#     chmod +x batery-mon.sh
#
# Instalar el chequedo a cada minuto
#  crontab -e
#
#    # m h  dom mon dow   command
#    */1 *   *   *   *   /srv/batery-mon.sh >> /srv/batery.log
#############################################################################################

#Estado de conexión AC
AC=`acpi -a | awk '{print $3}'`

#Porciento de carga de la batería
BATERIA=`acpi -b | awk '{print $4}'`

#Verificar si está conectado a la AC
if [ $AC = "on-line" ]; then 
  echo "Conectado a AC"
  echo `acpi -b`
  exit 0
else

 if [ $BATERIA = "100%" ]; then
     echo "Bateria cargada al 100%"
     exit 0
  else
     # Quitar carcater de porciento
     echo $BATERIA > bateria
     BATERIA=`cut -c 1-2 bateria`
     rm bateria

     # Verificación de estado de batería:
     if [ $BATERIA -ge 90 ]; then
       echo "AC: Desconectada"
       echo "Batería: " $BATERIA

     # Verificación de estado crítico de bateria
     elif [ $BATERIA -le 10 ]; then
       echo "AC: Desconectada"
       echo "Batería: " $BATERIA
       echo "Apagando sistema ..."

       #Guardar momento de apagado del sistema
       fecha=`date`
       echo "Bateria baja, apagando sistema "$fecha >> /srv/apagado.log

       #Mandar a apagar al sistema 
       /sbin/shutdown -h now
     fi
  fi
fi
