## Definimos el los directorios en los que eliminar sus hijos vacíos
$targetFolder = @("C:\inetpub\wwwroot\Imagenes\folder1", 
                  "C:\inetpub\wwwroot\Imagenes\folder2", 
                  "C:\inetpub\wwwroot\Ficheros\folder3", 
                  "C:\inetpub\wwwroot\Logs\folder4")

##  PSUDOCODE

#  1  RECOGEMOS LA INFORMACION DE TODOS LOS HIJOS DEL DIRECTORIO
#  Get-ChildItem $targetFolder -r

#  2  FILTRAMOS LOS QUE SON DIRECTORIOS
#  ? {$_.PSIsContainer -eq $True}

#  3  FILTRAMOS LOS QUE NO CONTIENEN NINGUN HIJO
#  ?{$_.GetFileSystemInfos().Count -eq 0}

#  4  BORRAR EL OBJETO
#  Remove-Item

For ($i=0; $i -lt $targetFolder.Length; $i++)
 {
  Get-ChildItem $targetFolder[$i] -r | ? {$_.PSIsContainer -eq $True} | ?{$_.GetFileSystemInfos().Count -eq 0} | Remove-Item
 }
